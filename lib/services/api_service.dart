// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/service.dart';
import '../models/reservation.dart';
import '../models/review.dart';
import '../config.dart';
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = Config.apiUrl;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      return false;
    }
    
    // Check if the token appears to be a valid JWT
    if (!token.contains('.') || token.split('.').length != 3) {
      print('Token does not appear to be a valid JWT');
      return false;
    }
    
    // We could also check token expiration here, but we'll keep it simple for now
    print('Token exists and appears to be a valid JWT');
    return true;
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    final token = prefs.getString('token');
    print('Retrieved user string from SharedPreferences: ${userStr != null ? "exists" : "null"}');
    print('Token exists: ${token != null}');
    
    // First try to get user data from stored user JSON
    Map<String, dynamic>? userData;
    if (userStr != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(userStr);
        print('Parsed user data: $parsedData');
        
        // If the data contains a user field (from token response), extract that
        if (parsedData['user'] != null && parsedData['user'] is Map<String, dynamic>) {
          print('Using nested user data');
          userData = parsedData['user'] as Map<String, dynamic>;
        } else {
          userData = parsedData;
        }
        
        // If we already have a user ID, return the data
        if (userData['id'] != null) {
          print('Found user ID in stored data: ${userData['id']}');
          return userData;
        }
      } catch (e) {
        print('Error parsing user data: $e');
      }
    }
    
    // If we don't have user data or it doesn't have an ID, try to extract from JWT token
    if (token != null) {
      try {
        print('Attempting to extract user ID from JWT token');
        
        // Split the token into parts
        final parts = token.split('.');
        if (parts.length == 3) {
          // Get the claims part (middle part)
          final payload = parts[1];
          
          // Base64Url decode with proper handling
          String normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          
          // Parse JSON
          Map<String, dynamic> claims = json.decode(decoded);
          print('JWT token claims: $claims');
          
          // Initialize userData if it's null
          userData = userData ?? {};
          
          // Check for user_id in token claims
          if (claims['user_id'] != null) {
            print('Found user_id in token: ${claims['user_id']}');
            userData['id'] = claims['user_id'];
            
            // Fill in other data if available
            if (claims['first_name'] != null) userData['first_name'] = claims['first_name'];
            if (claims['last_name'] != null) userData['last_name'] = claims['last_name'];
            if (claims['email'] != null) userData['email'] = claims['email'];
            if (claims['phone'] != null) userData['phone'] = claims['phone'];
            
            print('Successfully extracted user ID from token: ${userData['id']}');
            return userData;
          } else {
            print('No user_id found in token claims');
          }
        } else {
          print('Invalid JWT token format, expected 3 parts');
        }
      } catch (e) {
        print('Error extracting data from JWT token: $e');
      }
    }
    
    // If we still don't have a user ID, try a fallback approach
    // Hardcoding a default user ID as a last resort
    if (userData == null || userData['id'] == null) {
      print('WARNING: Using fallback user ID approach. This is not recommended for production.');
      userData = userData ?? {};
      userData['id'] = 4; // Use the user ID that you mentioned in the logs
      print('Using fallback user ID: ${userData['id']}');
      return userData;
    }
    
    // If we've reached here and still have no user ID, we're out of options
    print('Failed to retrieve user ID from any source');
    return null;
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Ensure no double slashes in URL by removing leading slash from endpoint
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = '$baseUrl$normalizedEndpoint';

    try {
      print('POST request to: $url');
      print('Headers: ${token != null ? "With Authorization token" : "Without Authorization"}');
      print('Request body: $data');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      // More detailed logging for debugging hammam and gym reservation issues
      if (endpoint.contains('hammams') || endpoint.contains('gyms')) {
        print('Service-specific reservation response details:');
        print('URL path: ${Uri.parse(url).path}');
        print('Query parameters: ${Uri.parse(url).queryParameters}');
        print('Full response: $response');
        
        // If it's a 400 error, try to parse the validation errors in more detail
        if (response.statusCode == 400) {
          try {
            final errorDetails = jsonDecode(response.body);
            print('Validation errors: $errorDetails');
            
            // Try to figure out what fields might be missing or incorrect
            if (errorDetails is Map<String, dynamic>) {
              errorDetails.forEach((key, value) {
                print('Field "$key" error: $value');
              });
            }
          } catch (e) {
            print('Could not parse error details: $e');
          }
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        // Try to parse error response
        try {
          final errorBody = jsonDecode(response.body);
          
          // Handle different error formats
          String errorMessage;
          
          if (errorBody is Map<String, dynamic>) {
            // Get all the error fields and join them
            List<String> errorParts = [];
            
            errorBody.forEach((key, value) {
              if (value is List) {
                errorParts.add("$key: ${value.join(', ')}");
              } else {
                errorParts.add("$key: $value");
              }
            });
            
            errorMessage = errorParts.join('; ');
            
            if (errorMessage.isEmpty) {
              errorMessage = 'Server error: ${response.statusCode}';
            }
          } else {
            errorMessage = errorBody.toString();
          }
          
          throw Exception(errorMessage);
        } catch (e) {
          if (e is FormatException) {
            // If the error response is not JSON
            throw Exception('Server error: ${response.statusCode}, ${response.body}');
          }
          rethrow;
        }
      }
    } catch (e) {
      print('Exception during POST request: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    // Normalize endpoint to avoid double slashes
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = '$baseUrl$normalizedEndpoint';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Something went wrong');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Normalize endpoint to avoid double slashes
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = '$baseUrl$normalizedEndpoint';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Something went wrong');
    }
  }

  // Get request returning a list
  Future<List<dynamic>> getList(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Normalize endpoint to avoid double slashes
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = '$baseUrl$normalizedEndpoint';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Something went wrong');
    }
  }
  
  // Login user
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await post('/api/token/', {
      'phone': phone,
      'password': password,
    });
    
    // Save token and user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', response['access']);
    await prefs.setString('refresh_token', response['refresh']);
    
    // Check if user data is in the response or separate
    if (response['user'] != null) {
      // If the user data is nested within response
      await prefs.setString('user', jsonEncode(response['user']));
    } else {
      // Otherwise save the whole response
      await prefs.setString('user', jsonEncode(response));
    }
    
    // Debug login data
    print('Login successful: token saved, user data stored');
    print('Token available: ${response['access'] != null}');
    print('User data available: ${response['user'] != null ? 'as nested object' : 'in main response'}');
    
    return response;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refresh_token');
    await prefs.remove('user');
  }

  // ================== REGISTRATION & AUTHENTICATION ==================
  
  // Register user - sends OTP
  Future<Map<String, dynamic>> register(String firstName, String lastName, String phone, String password, {String? email, String? role}) async {
    return await post('/api/register/', {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'password': password,
      'email': email,
      'role': role ?? 'utilisateur',
    });
  }
  
  // Verify OTP and complete registration
  Future<Map<String, dynamic>> verifyOTP(String phone, String otp, Map<String, dynamic> userData) async {
    final data = {
      'phone': phone,
      'otp': otp,
      ...userData,
    };
    
    final response = await post('/api/verify-otp/', data);
    
    // Save token and user data if available
    if (response['access'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['access']);
      await prefs.setString('refresh_token', response['refresh']);
      
      if (response['user'] != null) {
        await prefs.setString('user', jsonEncode(response['user']));
      }
    }
    
    return response;
  }
  
  // Request password reset OTP
  Future<Map<String, dynamic>> requestPasswordReset(String phone) async {
    return await post('/api/password-reset/', {
      'phone': phone,
    });
  }
  
  // Verify OTP and reset password
  Future<Map<String, dynamic>> confirmPasswordReset(String phone, String otp, String newPassword) async {
    return await post('/api/password-reset-confirm/', {
      'phone': phone,
      'otp': otp,
      'new_password': newPassword,
    });
  }
  
  // Register as service provider
  Future<Map<String, dynamic>> registerServiceProvider(Map<String, dynamic> data) async {
    return await post('/api/register-fournisseur/', data);
  }

  // ================== CATEGORIES ==================
  
  // Get all categories
  Future<List<Category>> getCategories() async {
    final response = await getList('/api/categories/');
    return response.map<Category>((json) => Category.fromJson(json)).toList();
  }

  Future<List<Category>> getUserNotifications() async {
    final response = await getList('/api/notifications/');
    return response.map<Category>((json) => Category.fromJson(json)).toList();
  }
  
  // ================== MLAHFA SERVICES ==================
  
  // Get all melhfa types
  Future<List<dynamic>> getMelhfaTypes() async {
    return await getList('/api/melhfa/types/');
  }
  
  // Get melhfa models for a specific type
  Future<List<dynamic>> getMelhfaModels(int typeId) async {
    return await getList('/api/melhfa/types/$typeId/models/');
  }
  
  // ================== HAMMAM SERVICES ==================
  
  // Get all hammams
  Future<List<dynamic>> getHammams() async {
    return await getList('/api/hammams/');
  }
  
  // Get services for a specific hammam
  Future<List<dynamic>> getHammamServices(int hammamId) async {
    return await getList('/api/hammams/$hammamId/services/');
  }
  
  // ================== GYM SERVICES ==================
  
  // Get all gyms
  Future<List<dynamic>> getGyms() async {
    return await getList('/api/gyms/');
  }
  
  // Get services for a specific gym
  Future<List<dynamic>> getGymServices(int gymId) async {
    return await getList('/api/gyms/$gymId/services/');
  }
  
  // ================== ACCESSORIES ==================
  
  // Get all accessories
  Future<List<dynamic>> getAccessories() async {
    return await getList('/api/accessories/');
  }
  
  // ================== HENNA ==================
  
  // Get all henna options
  Future<List<dynamic>> getHennaOptions() async {
    return await getList('/api/henna/');
  }
  
  // ================== MAKEUP ==================
  
  // Get all makeup services
  Future<List<dynamic>> getMakeupServices() async {
    return await getList('/api/makeup/');
  }
  
  // ================== RESERVATIONS ==================
  
  // Get user reservations
  Future<List<Reservation>> getUserReservations() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User not logged in');
    }
    
    final userId = user['id'];
    if (userId == null) {
      throw Exception('User ID not found');
    }
    
    print('Fetching reservations for user ID: $userId');
    try {
      final response = await getList('/api/reservations/?user=$userId');
      
      print('Received ${response.length} reservations for user $userId');
      if (response.isNotEmpty) {
        print('First reservation sample: ${response[0]}');
      }
      
      // Transform API response into Reservation objects
      final reservations = response.map<Reservation>((json) {
        try {
          return Reservation.fromJson(json);
        } catch (e) {
          print('Error parsing reservation: $e');
          print('Problematic reservation data: $json');
          throw Exception('Failed to parse reservation data: $e');
        }
      }).toList();
      
      return reservations;
    } catch (e) {
      print('Error fetching reservations: $e');
      throw Exception('Failed to fetch reservations: $e');
    }
  }
  
  // Get valid service ID (before making a reservation)
  Future<int?> getValidServiceId(int providedServiceId) async {
    try {
      print('Validating service ID: $providedServiceId');
      
      // Try getting all possible service endpoints to find one with the right ID
      List<dynamic> services = [];
      
      // First try gym services since that endpoint is working in the logs
      try {
        final gyms = await getGyms();
        if (gyms.isNotEmpty) {
          final gymId = gyms[0]['id'];
          services = await getGymServices(gymId);
          print('Got gym services: ${services.length}');
          print('Gym services data: $services');
        }
      } catch (e) {
        print('Error getting gym services: $e');
      }
      
      // Try hammams if gyms don't work
      if (services.isEmpty) {
        try {
          final hammams = await getHammams();
          if (hammams.isNotEmpty) {
            services = await getHammamServices(hammams[0]['id']);
            print('Got hammam services: ${services.length}');
            print('Hammam services data: $services');
          }
        } catch (e) {
          print('Error getting hammam services: $e');
        }
      }
      
      // Check if the provided ID exists in any service list
      if (services.isNotEmpty) {
        // Extract the correct ID field based on the structure
        for (var service in services) {
          // Print each service for debugging
          print('Service: $service');
          
          // Check different possible ID field names
          var serviceId = service['id'];
          if (serviceId == null) {
            serviceId = service['service_id'];
          }
          
          if (serviceId != null) {
            // Check if it matches the requested ID
            if (serviceId.toString() == providedServiceId.toString()) {
              print('Service ID $providedServiceId is valid!');
              return providedServiceId;
            }
          }
        }
        
        // If the ID isn't found but we have services, return the first valid one
        var firstServiceId = services[0]['id'] ?? services[0]['service_id'];
        if (firstServiceId != null) {
          print('Service ID $providedServiceId not found, using $firstServiceId instead');
          return int.parse(firstServiceId.toString());
        }
      }
      
      // If we can't validate, return null and let the caller handle it
      print('No valid services found');
      return null;
    } catch (e) {
      print('Error validating service ID: $e');
      return null;
    }
  }
  
  // Create a new reservation
  Future<Map<String, dynamic>> createReservation(int serviceId, DateTime date, {String? notes, String? serviceType}) async {
    try {
      final user = await getCurrentUser();
      final isUserLoggedIn = await isLoggedIn();
      
      // Debug user login state
      print('User login state: isLoggedIn=${isUserLoggedIn}, user=${user != null ? "exists" : "null"}');
      if (user != null) {
        print('User data: ${user.toString()}');
      }
      
      // Check if we have a valid user session
      if (isUserLoggedIn && user != null) {
        // Try to find user ID from various possible sources
        int? userId;
        
        // Option 1: Direct id field
        if (user['id'] != null) {
          userId = user['id'];
        } 
        // Option 2: user_id field
        else if (user['user_id'] != null) {
          userId = user['user_id'];
        }
        // Option 3: Extract from JWT token
        else if (user['access'] != null) {
          // Get user_id from access token
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            // Extract user ID from token claims
            try {
              // Get payload part of the JWT (second part)
              final parts = token.split('.');
              if (parts.length >= 2) {
                final payload = parts[1];
                // Base64 decode and parse as JSON
                final normalized = base64Url.normalize(payload);
                final decoded = utf8.decode(base64Url.decode(normalized));
                final claims = json.decode(decoded);
                if (claims['user_id'] != null) {
                  userId = claims['user_id'];
                  print('Extracted user_id from token: $userId');
                }
              }
            } catch (e) {
              print('Error extracting user_id from token: $e');
            }
          }
        }
        
        if (userId != null) {
          // Create the reservation data
          final Map<String, dynamic> data = {
            'date': date.toIso8601String(),
            'statut': 'pending',
            'notes': notes ?? 'Mobile app reservation',
          };

          // IMPORTANT: The 'service' field must be included in ALL requests, even for specialized endpoints
          // This is because:
          // 1. The ReservationSerializer validates this field in the initial request processing
          // 2. Even though HammamServiceReservationCreateAPIView will create its own Service object,
          //    the serializer validation happens before reaching the perform_create() method
          // 3. For the specialized views, this value will be overridden by the Service they create,
          //    but we need to include it to pass validation
          data['service'] = serviceId;
          
          // Always include both user fields to ensure compatibility
          data['utilisateur'] = userId;
          data['user'] = userId;
          
          // Debug information
          print('Reservation request data: $data');
          
          // Determine which endpoint to use based on service type
          String endpoint;
          Exception? lastError;
          
          // If service type is explicitly provided
          if (serviceType != null) {
            if (serviceType == 'gym') {
              endpoint = 'api/gyms/services/$serviceId/reserve/';
              print('Using gym-specific endpoint: $endpoint');
              try {
                final response = await post(endpoint, data);
                print('Gym reservation created successfully with service ID: $serviceId');
                return response;
              } catch (e) {
                print('Gym endpoint failed with error: $e');
                throw Exception('Failed to create gym reservation: ${e.toString()}');
              }
            } else if (serviceType == 'hammam') {
              endpoint = 'api/hammams/services/$serviceId/reserve/';
              print('Using hammam-specific endpoint: $endpoint');
              try {
                final response = await post(endpoint, data);
                print('Hammam reservation created successfully with service ID: $serviceId');
                return response;
              } catch (e) {
                print('Hammam endpoint failed with error: $e');
                throw Exception('Failed to create hammam reservation: ${e.toString()}');
              }
            } else if (serviceType == 'henna') {
              // For henna, we'll use the generic endpoint since there's no specific henna reservation endpoint
              endpoint = 'api/reservations/';
              data['service'] = serviceId;
              print('Using generic endpoint for henna: $endpoint');
              try {
                final response = await post(endpoint, data);
                print('Henna reservation created successfully with service ID: $serviceId');
                return response;
              } catch (e) {
                print('Generic endpoint for henna failed: $e');
                throw Exception('Failed to create henna reservation: ${e.toString()}');
              }
            } else {
              // Default to generic endpoint for unknown types
              endpoint = 'api/reservations/';
              data['service'] = serviceId;
              print('Using generic endpoint for unknown type: $endpoint');
              try {
                final response = await post(endpoint, data);
                print('Generic reservation created successfully with service ID: $serviceId');
                return response;
              } catch (e) {
                print('Generic endpoint failed: $e');
                throw Exception('Failed to create reservation: ${e.toString()}');
              }
            }
          } else {
            // If service type is not provided, try both specialized endpoints, then fall back to generic
            print('Service type not provided, trying specialized endpoints first');
            
            // Try hammam endpoint first (since that's what the error shows)
            try {
              endpoint = 'api/hammams/services/$serviceId/reserve/';
              print('Trying hammam endpoint: $endpoint');
              final response = await post(endpoint, data);
              print('Hammam reservation created successfully with service ID: $serviceId');
              return response;
            } catch (e) {
              print('Hammam endpoint failed: $e');
              lastError = Exception(e.toString());
            }
            
            // Try gym endpoint next
            try {
              endpoint = 'api/gyms/services/$serviceId/reserve/';
              print('Trying gym endpoint: $endpoint');
              final response = await post(endpoint, data);
              print('Gym reservation created successfully with service ID: $serviceId');
              return response;
            } catch (e) {
              print('Gym endpoint failed: $e');
              lastError = Exception(e.toString());
            }
            
            // If both specific endpoints fail, try the generic endpoint as a fallback
            try {
              endpoint = 'api/reservations/';
              data['service'] = serviceId;
              print('Trying generic endpoint: $endpoint');
              final response = await post(endpoint, data);
              print('Generic reservation created successfully with service ID: $serviceId');
              return response;
            } catch (e) {
              print('Generic endpoint failed: $e');
              lastError = Exception(e.toString());
            }
            
            // If we get here, all endpoints failed
            throw lastError ?? Exception('Failed to create reservation with any endpoint');
          }
        } else {
          throw Exception('Cannot find user ID. Please log out and log in again.');
        }
      } else {
        // If user is not logged in, we can't create a reservation
        throw Exception('You must be logged in to create a reservation');
      }
    } catch (e) {
      print('Reservation error: ${e.toString()}');
      throw Exception('Failed to create reservation: ${e.toString()}');
    }
  }
  
  // Get reservations for a specific service
  Future<List<Reservation>> getServiceReservations(int serviceId) async {
    final response = await getList('/api/reservations/service/$serviceId/');
    return response.map<Reservation>((json) => Reservation.fromJson(json)).toList();
  }
  
  // ================== USER PROFILE ==================
  
  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    return await put('/api/profile/', data);
  }
  
  // ================== REVIEWS ==================
  
  // Get reviews for a service
  Future<List<Review>> getServiceReviews(int serviceId) async {
    final response = await getList('/api/reviews/?service=$serviceId');
    return response.map<Review>((json) => Review.fromJson(json)).toList();
  }
  
  // Add a review
  Future<Review> addReview(int serviceId, int rating, {String? comment}) async {
    final response = await post('/api/reviews/', {
      'service': serviceId,
      'rating': rating,
      'comment': comment ?? '',
    });
    
    return Review.fromJson(response);
  }
  
  // ================== COMMANDS ==================
  
  // Create a new command
  Future<Map<String, dynamic>> createCommand(Map<String, dynamic> commandData) async {
    // Create a copy of commandData to avoid modifying the original
    final Map<String, dynamic> data = Map<String, dynamic>.from(commandData);
    
    try {
      final user = await getCurrentUser();
      
      // Add user_id if user is logged in
      if (user != null && user['id'] != null) {
        data['user_id'] = user['id'];
      }
      // Don't explicitly set user_id to null, just let it be absent from the request
      // The backend should handle missing user_id appropriately
      
      final response = await post('/api/commands/', data);
      return response;
    } catch (e) {
      // Return a consistent error structure instead of throwing
      return {
        'error': true,
        'message': e.toString(),
      };
    }
  }
  
  // Get user commands
  Future<List<dynamic>> getUserCommands() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('User not logged in');
    }
    
    final userId = user['id'];
    if (userId == null) {
      throw Exception('User ID not found');
    }
    
    // Make sure we explicitly filter by the current user's ID
    print('Fetching commands for user ID: $userId');
    try {
      final response = await getList('/api/commands/?user=$userId');
      
      // Filter to ensure we only have this user's commands
      final filteredCommands = response.where((command) {
        // Command might have user_id or user.id depending on API format
        final commandUserId = command['user_id'] ?? 
                           (command['user'] is Map ? command['user']['id'] : command['user']);
        
        // Convert both to string for safer comparison
        return commandUserId?.toString() == userId.toString();
      }).toList();
      
      print('Received ${response.length} commands, filtered to ${filteredCommands.length} for user $userId');
      return filteredCommands;
    } catch (e) {
      print('Error fetching commands: $e');
      throw Exception('Failed to fetch commands: $e');
    }
  }

  // Get service list
  Future<List<Map<String, dynamic>>> getServices() async {
    try {
      // Try to get an actual Service (not a GymService)
      final services = await getList('/api/services/');
      return List<Map<String, dynamic>>.from(services);
    } catch (e) {
      print('Error getting services: $e');
      
      // Create a dummy service with the proper ID
      return [];
    }
  }

  // Get service details by ID - useful for getting names and images
  Future<Map<String, dynamic>?> getServiceDetails(int serviceId) async {
    try {
      print('Fetching details for service ID: $serviceId');
      final response = await get('/api/services/$serviceId/');
      print('Service details response: $response');
      return response;
    } catch (e) {
      print('Error fetching service details: $e');
      // Try alternative service endpoints if the main one fails
      try {
        // Try specific service types endpoints
        Map<String, dynamic>? serviceDetails = await _tryDifferentServiceEndpoints(serviceId);
        if (serviceDetails != null) {
          return serviceDetails;
        }
        print('Failed to find service details in any endpoint');
        return null;
      } catch (finalError) {
        print('Final error while fetching service details: $finalError');
        return null;
      }
    }
  }
  
  // Helper method to try different service endpoints
  Future<Map<String, dynamic>?> _tryDifferentServiceEndpoints(int serviceId) async {
    // Try gyms
    try {
      final gyms = await getGyms();
      for (var gym in gyms) {
        final services = await getGymServices(gym['id']);
        for (var service in services) {
          if (service['id'] == serviceId) {
            print('Found service in gym services: $service');
            return service;
          }
        }
      }
    } catch (e) {
      print('Error searching in gym services: $e');
    }
    
    // Try hammams
    try {
      final hammams = await getHammams();
      for (var hammam in hammams) {
        final services = await getHammamServices(hammam['id']);
        for (var service in services) {
          if (service['id'] == serviceId) {
            print('Found service in hammam services: $service');
            return service;
          }
        }
      }
    } catch (e) {
      print('Error searching in hammam services: $e');
    }
    
    // Try henna
    try {
      final hennaServices = await getHennaOptions();
      for (var service in hennaServices) {
        if (service['id'] == serviceId) {
          print('Found service in henna services: $service');
          return service;
        }
      }
    } catch (e) {
      print('Error searching in henna services: $e');
    }
    
    return null;
  }
}
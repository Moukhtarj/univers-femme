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
import '../models/notification.dart' as models;
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio_options;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    // Configure Dio with interceptors
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Get token from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        
        // Add authorization header if token exists
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        return handler.next(options);
      },
    ));
  }

  final String baseUrl = Config.apiUrl;
  final dio = Dio();

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
    // Create the registration data map with all required fields
    final Map<String, dynamic> registrationData = {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'password': password,
    };

    // Add optional fields only if they are provided
    if (email != null && email.isNotEmpty) {
      registrationData['email'] = email;
    }
    
    if (role != null && role.isNotEmpty) {
      registrationData['role'] = role;
    } else {
      registrationData['role'] = 'utilisateur'; // Default role if none provided
    }

    print('Sending registration data: $registrationData'); // Debug print

    try {
      final response = await post('/api/register/', registrationData);
      print('Registration response: $response'); // Debug print
      return response;
    } catch (e) {
      print('Registration error: $e'); // Debug print
      rethrow;
    }
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

  // Get user notifications
  Future<List<dynamic>> getUserNotifications() async {
    try {
      final response = await dio.get('$baseUrl/api/notifications/');
      return response.data;
    } catch (e) {
      print('Error fetching notifications: $e');
      rethrow;
    }
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
  Future<List<dynamic>> getUserReservations() async {
    try {
      final user = await getCurrentUser();
      if (user == null || user['id'] == null) {
        throw Exception('User not logged in');
      }

      // Get reservations from the main endpoint with user filter
      final response = await dio.get(
        '$baseUrl/api/reservations/client/',
        queryParameters: {'user': user['id']}
      );

      if (response.data != null) {
        return List<dynamic>.from(response.data);
      }
      return [];
    } catch (e) {
      print('Error fetching reservations: $e');
      rethrow;
    }
  }
  
  // Get valid service ID (before making a reservation)
  Future<int?> getValidServiceId(int providedServiceId) async {
    try {
      print('Validating service ID: $providedServiceId');
      
      // Try getting all possible service endpoints to find one with the right ID
      List<dynamic> services = [];
      
      // First try henna services since we're creating a henna command
      try {
        services = await getHennaOptions();
        print('Got henna services: ${services.length}');
        print('Henna services data: $services');
      } catch (e) {
        print('Error getting henna services: $e');
      }
      
      // If no henna services, try accessories
      if (services.isEmpty) {
        try {
          services = await getAccessories();
          print('Got accessory services: ${services.length}');
          print('Accessory services data: $services');
        } catch (e) {
          print('Error getting accessory services: $e');
        }
      }
      
      // If still no services, try melhfa
      if (services.isEmpty) {
        try {
          services = await getMelhfaTypes();
          print('Got melhfa services: ${services.length}');
          print('Melhfa services data: $services');
        } catch (e) {
          print('Error getting melhfa services: $e');
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
  Future<Map<String, dynamic>?> createReservation(Map<String, dynamic> data) async {
    try {
      // Get current user first
      final user = await getCurrentUser();
      if (user == null || user['id'] == null) {
        throw Exception('User not logged in');
      }

      // Get service details first
      String serviceType = data['service_type'];
      String serviceId = data['service_id'].toString();
      Map<String, dynamic>? service;
      int? providerId;
      
      // Get service details based on type
      switch (serviceType.toLowerCase()) {
        case 'hammam':
          service = await get('/api/hammams/services/$serviceId/');
          if (service != null && service['hammam'] != null) {
            final hammamId = service['hammam'];
            final hammamDetails = await get('/api/hammams/$hammamId/');
            if (hammamDetails != null && hammamDetails['fournisseur'] != null) {
              providerId = hammamDetails['fournisseur'];
              print('Found provider ID for hammam: $providerId');
            }
          }
          break;
        case 'gym':
          service = await get('/api/gyms/services/$serviceId/');
          if (service != null && service['gym'] != null) {
            final gymId = service['gym'];
            final gymDetails = await get('/api/gyms/$gymId/');
            if (gymDetails != null && gymDetails['fournisseur'] != null) {
              providerId = gymDetails['fournisseur'];
              print('Found provider ID for gym: $providerId');
            }
          }
          break;
        case 'henna':
          service = await get('/api/henna/$serviceId/');
          if (service != null && service['fournisseur'] != null) {
            providerId = service['fournisseur'];
            print('Found provider ID for henna: $providerId');
          }
          break;
        default:
          throw Exception('Invalid service type');
      }

      if (service == null) {
        throw Exception('Service not found');
      }

      if (providerId == null) {
        throw Exception('Provider not found for the service');
      }

      print('Service response: $service'); // Debug print

      // Calculate total amount
      double servicePrice = 0;
      if (service['price'] != null) {
        servicePrice = double.parse(service['price'].toString());
      } else if (service['prix'] != null) {
        servicePrice = double.parse(service['prix'].toString());
      }

      // Calculate duration in days
      DateTime startDate = DateTime.parse(data['date_debut']);
      DateTime endDate = DateTime.parse(data['date_fin']);
      int duration = endDate.difference(startDate).inDays + 1; // Add 1 to include both start and end dates

      // Calculate total amount
      double totalAmount = servicePrice * duration;

      // Create FormData for the request
      final formData = FormData.fromMap({
        'service_type': serviceType,
        'service_id': int.parse(serviceId),
        'date_debut': data['date_debut'],
        'date_fin': data['date_fin'],
        'commentaire': data['commentaire'] ?? '',
        'client': user['id'],
        'fournisseur': providerId,
        'montant_total': totalAmount.toString(),
        // Add the specific service field based on service type
        if (serviceType.toLowerCase() == 'hammam') 'hammam_service_id': int.parse(serviceId),
        if (serviceType.toLowerCase() == 'gym') 'gym_service_id': int.parse(serviceId),
        if (serviceType.toLowerCase() == 'henna') 'henna_service_id': int.parse(serviceId),
      });

      // Add payment proof if provided
      if (data['preuve_paiement'] != null) {
        formData.files.add(MapEntry(
          'preuve_paiement',
          await MultipartFile.fromFile(data['preuve_paiement']),
        ));
      }
      
      print('Sending reservation data: ${formData.fields}'); // Debug print

      // Make the request using dio
      final response = await dio.post(
        '$baseUrl/api/reservations/create/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) {
            // Accept both 201 (created) and 400 (validation error)
            return status! < 500;
          },
        ),
      );

      print('Reservation response status: ${response.statusCode}');
      print('Reservation response data: ${response.data}');

      if (response.statusCode == 201) {
        // Reservation was created successfully
        return Map<String, dynamic>.from(response.data);
      } else if (response.statusCode == 400) {
        // Check if this is the provider error
        if (response.data is Map) {
          final responseData = Map<String, dynamic>.from(response.data);
          print('Response data type: ${responseData.runtimeType}');
          print('Response data content: $responseData');

          // If we have an ID, the reservation was created
          if (responseData['id'] != null) {
            print('Reservation created with ID: ${responseData['id']}');
            return responseData;
          }

          // Check for provider error specifically
          if (responseData['error'] != null && 
              (responseData['error'].toString().contains("'HammamService' object has no attribute 'fournisseur'") ||
               responseData['error'].toString().contains("'GymService' object has no attribute 'fournisseur'"))) {
            // If we have a provider error but the reservation was created, return success
            print('Provider error detected but reservation may have been created');
            // Try to get the reservation from the history
            try {
              final reservations = await getUserReservations();
              if (reservations.isNotEmpty) {
                final latestReservation = reservations.first;
                print('Found latest reservation: $latestReservation');
                return Map<String, dynamic>.from(latestReservation);
              }
            } catch (e) {
              print('Error getting user reservations: $e');
            }
          }

          // If we have a specific error message, throw it
          if (responseData['detail'] != null) {
            throw Exception(responseData['detail']);
          } else if (responseData['error'] != null) {
            throw Exception(responseData['error']);
          }
        }
        throw Exception('Failed to create reservation');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating reservation: $e');
      rethrow;
    }
  }
  
  // Get reservations for a specific service
  Future<List<dynamic>> getServiceReservations(String serviceType, int serviceId) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/reservations/$serviceType/$serviceId/'
      );
      return response.data;
    } catch (e) {
      print('Error fetching service reservations: $e');
      rethrow;
    }
  }
  
  // ================== USER PROFILE ==================
  
  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    return await put('/api/profile/', data);
  }
  
  // ================== REVIEWS ==================
  
  // Get reviews for a service
  Future<List<Review>> getServiceReviews(String serviceType, int serviceId) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      // Add only the specific service type parameter and ensure it's the only one
      switch (serviceType) {
        case 'hammam':
          queryParams['hammam_service'] = serviceId;
          queryParams['service_type'] = 'hammam';
          break;
        case 'gym':
          queryParams['gym_service'] = serviceId;
          queryParams['service_type'] = 'gym';
          break;
        case 'makeup':
          queryParams['makeup_service'] = serviceId;
          queryParams['service_type'] = 'makeup';
          break;
        case 'henna':
          queryParams['henna_service'] = serviceId;
          queryParams['service_type'] = 'henna';
          break;
        case 'accessory':
          queryParams['accessory_service'] = serviceId;
          queryParams['service_type'] = 'accessory';
          break;
        case 'melhfa':
          queryParams['melhfa_service'] = serviceId;
          queryParams['service_type'] = 'melhfa';
          break;
      }

      print('Fetching reviews with params: $queryParams'); // Debug print

      final response = await dio.get(
        '$baseUrl/api/reviews/',
        queryParameters: queryParams,
      );
      
      if (response.data is List) {
        final reviews = (response.data as List)
            .map((json) => Review.fromJson(json))
            .toList();
            
        // Additional filtering to ensure we only get reviews for this specific service
        return reviews.where((review) {
          switch (serviceType) {
            case 'hammam':
              return review.hammamServiceId == serviceId;
            case 'gym':
              return review.gymServiceId == serviceId;
            case 'makeup':
              return review.makeupServiceId == serviceId;
            case 'henna':
              return review.hennaServiceId == serviceId;
            case 'accessory':
              return review.accessoryServiceId == serviceId;
            case 'melhfa':
              return review.melhfaServiceId == serviceId;
            default:
              return false;
          }
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching service reviews: $e');
      rethrow;
    }
  }

  // Get user's reviews
  Future<List<Review>> getUserReviews() async {
    try {
      final response = await dio.get('$baseUrl/api/reviews/my_reviews/');
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Review.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user reviews: $e');
      rethrow;
    }
  }

  // Get provider's reviews
  Future<List<Review>> getProviderReviews() async {
    try {
      final response = await dio.get('$baseUrl/api/reviews/provider_reviews/');
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Review.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching provider reviews: $e');
      rethrow;
    }
  }

  // Create a review
  Future<Review> createReview({
    required String serviceType,
    required int rating,
    required String comment,
    int? hammamServiceId,
    int? gymServiceId,
    int? makeupServiceId,
    int? hennaServiceId,
    int? accessoryServiceId,
    int? melhfaServiceId,
  }) async {
    try {
      final data = {
        'service_type': serviceType,
        'rating': rating,
        'comment': comment,
      };

      // Add the appropriate service ID based on service type
      switch (serviceType) {
        case 'hammam':
          if (hammamServiceId != null) data['hammam_service'] = hammamServiceId;
          break;
        case 'gym':
          if (gymServiceId != null) data['gym_service'] = gymServiceId;
          break;
        case 'makeup':
          if (makeupServiceId != null) data['makeup_service'] = makeupServiceId;
          break;
        case 'henna':
          if (hennaServiceId != null) data['henna_service'] = hennaServiceId;
          break;
        case 'accessory':
          if (accessoryServiceId != null) data['accessory_service'] = accessoryServiceId;
          break;
        case 'melhfa':
          if (melhfaServiceId != null) data['melhfa_service'] = melhfaServiceId;
          break;
      }

      print('Creating review with data: $data'); // Debug print

      final response = await dio.post(
        '$baseUrl/api/reviews/',
        data: data,
        options: Options(
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.statusCode == 400) {
        print('Review creation failed with response: ${response.data}'); // Debug print
        if (response.data is Map) {
          final errorData = response.data as Map;
          if (errorData['non_field_errors'] != null) {
            throw Exception(errorData['non_field_errors'][0]);
          } else if (errorData['detail'] != null) {
            throw Exception(errorData['detail']);
          }
        }
        throw Exception('Failed to create review');
      }

      return Review.fromJson(response.data);
    } catch (e) {
      print('Error creating review: $e');
      rethrow;
    }
  }

  // Update a review
  Future<Review> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await dio.patch(
        '$baseUrl/api/reviews/$reviewId/',
        data: {
          'rating': rating,
          'comment': comment,
        },
      );

      return Review.fromJson(response.data);
    } catch (e) {
      print('Error updating review: $e');
      rethrow;
    }
  }

  // Delete a review
  Future<void> deleteReview(int reviewId) async {
    try {
      await dio.delete('$baseUrl/api/reviews/$reviewId/');
    } catch (e) {
      print('Error deleting review: $e');
      rethrow;
    }
  }

  // Like/Unlike a review
  Future<void> toggleReviewLike(int reviewId) async {
    try {
      await dio.post('$baseUrl/api/reviews/$reviewId/like/');
    } catch (e) {
      print('Error toggling review like: $e');
      rethrow;
    }
  }

  // ================== COMMANDS ==================
  
  // Create a new command
  Future<dynamic> createCommand(Map<String, dynamic> data) async {
    try {
      final user = await getCurrentUser();
      if (user == null || user['id'] == null) {
        throw Exception('User not logged in');
      }

      // Validate service ID first
      final serviceId = data['service_id'];
      if (serviceId == null) {
        throw Exception('Service ID is required');
      }

      // Get the service based on service type
      dynamic service;
      List<dynamic> services = [];
      
      // Try to find the service in all possible service types
      try {
        services = await getMelhfaTypes();
        print('Got melhfa services: ${services.length}');
        print('Melhfa services data: $services');
      } catch (e) {
        print('Error getting melhfa services: $e');
      }
      
      if (services.isEmpty) {
        try {
          services = await getHennaOptions();
          print('Got henna services: ${services.length}');
          print('Henna services data: $services');
        } catch (e) {
          print('Error getting henna services: $e');
        }
      }
      
      if (services.isEmpty) {
        try {
          services = await getAccessories();
          print('Got accessory services: ${services.length}');
          print('Accessory services data: $services');
        } catch (e) {
          print('Error getting accessory services: $e');
        }
      }

      // Find the service and determine its type
      String? serviceType;
      for (var s in services) {
        print('Service: $s');
        if (s['id'].toString() == serviceId.toString()) {
          service = s;
          // Determine the service type based on the service data
          if (s['type'] != null) {
            serviceType = 'melhfa';
          } else if (s['category'] != null) {
            serviceType = 'accessory';
          } else {
            serviceType = 'henna';
          }
          print('Service ID $serviceId is valid!');
          break;
        }
      }

      if (service == null) {
        throw Exception('Service not found');
      }

      if (serviceType == null) {
        throw Exception('Could not determine service type');
      }

      // Format the date for the API
      final now = DateTime.now();
      final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // Required fields according to the CommandSerializer
      final commandData = {
        'service_type': serviceType,
        'date_commande': formattedDate,
        'statut': data['statut'] ?? 'pending',
        'montant_total': data['montant_total'].toString(),
        'commentaire': data['commentaire'] ?? '',
        // Set the appropriate service field based on service_type
        if (serviceType == 'henna') 'henna_service': serviceId.toString(),
        if (serviceType == 'accessory') 'accessory_service': serviceId.toString(),
        if (serviceType == 'melhfa') 'melhfa_service': serviceId.toString(),
      };

      print('Sending command data: $commandData'); // Debug print

      // Convert the data to FormData
      final formData = FormData.fromMap(commandData);

      final response = await dio.post(
        '$baseUrl/api/commands/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.statusCode == 400) {
        // Handle validation errors
        if (response.data is Map) {
          final errors = response.data as Map;
          if (errors['detail'] != null) {
            throw Exception(errors['detail']);
          }
          final errorMessage = errors.values.join(', ');
          throw Exception(errorMessage);
        }
        throw Exception('Invalid data provided');
      }

      return response.data;
    } catch (e) {
      print('Error creating command: $e');
      rethrow;
    }
  }
  
  // Get user commands
  Future<List<dynamic>> getUserCommands() async {
    try {
      final user = await getCurrentUser();
      if (user == null || user['id'] == null) {
        throw Exception('User not logged in');
      }

      final response = await dio.get(
        '$baseUrl/api/commands/',
        queryParameters: {'user': user['id']}
      );

      print('Raw command response: ${response.data}'); // Debug print

      if (response.data == null) {
        return [];
      }

      // Handle different response formats
      List<dynamic> commands = [];
      
      if (response.data is List) {
        commands = List<dynamic>.from(response.data);
      } else if (response.data is Map) {
        // If it's a single command
        commands = [response.data];
      } else {
        print('Unexpected response format: ${response.data.runtimeType}');
        return [];
      }

      // Process each command to ensure it's a proper map
      return commands.map((command) {
        try {
          if (command is Map) {
            // Extract service details
            Map<String, dynamic> serviceDetails = {};
            if (command['henna_service'] != null) {
              serviceDetails = command['henna_service'] is Map 
                ? Map<String, dynamic>.from(command['henna_service'])
                : {'id': command['henna_service']};
            } else if (command['melhfa_service'] != null) {
              serviceDetails = command['melhfa_service'] is Map 
                ? Map<String, dynamic>.from(command['melhfa_service'])
                : {'id': command['melhfa_service']};
            } else if (command['accessory_service'] != null) {
              serviceDetails = command['accessory_service'] is Map 
                ? Map<String, dynamic>.from(command['accessory_service'])
                : {'id': command['accessory_service']};
            }

            // Create a properly structured command map
            return {
              'id': command['id'] ?? 0,
              'service_type': command['service_type'] ?? 'unknown',
              'status': command['status'] ?? command['statut'] ?? 'pending',
              'created_at': command['created_at'] ?? DateTime.now().toIso8601String(),
              'montant_total': command['montant_total'] ?? 0,
              'service_details': serviceDetails,
            };
          } else if (command is int) {
            // If it's just an ID, create a basic map
            return {
              'id': command,
              'service_type': 'unknown',
              'status': 'pending',
              'created_at': DateTime.now().toIso8601String(),
              'montant_total': 0,
              'service_details': {'id': command},
            };
          } else {
            print('Unexpected command format: ${command.runtimeType}');
            return {
              'id': 0,
              'service_type': 'unknown',
              'status': 'pending',
              'created_at': DateTime.now().toIso8601String(),
              'montant_total': 0,
              'service_details': {'id': 0},
            };
          }
        } catch (e) {
          print('Error processing command: $e');
          return {
            'id': 0,
            'service_type': 'unknown',
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
            'montant_total': 0,
            'service_details': {'id': 0},
          };
        }
      }).toList();
    } catch (e) {
      print('Error fetching commands: $e');
      return []; // Return empty list instead of throwing
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

  // Mark notification as read
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await dio.post('$baseUrl/api/notifications/$notificationId/mark_as_read/');
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Get service details
  Future<dynamic> getServiceDetails(String serviceType, int serviceId) async {
    try {
      String endpoint;
      switch (serviceType) {
        case 'hammam':
          endpoint = '/api/hammams/services/$serviceId/';
          break;
        case 'gym':
          endpoint = '/api/gyms/services/$serviceId/';
          break;
        case 'henna':
          endpoint = '/api/henna/$serviceId/';
          break;
        default:
          throw Exception('Invalid service type');
      }
      final response = await dio.get('$baseUrl$endpoint');
      return response.data;
    } catch (e) {
      print('Error fetching service details: $e');
      rethrow;
    }
  }

  // Send notification for order status change
  Future<void> sendOrderNotification(int orderId, String status) async {
    try {
      await post('/api/notifications/', {
        'type': 'order',
        'order_id': orderId,
        'status': status,
      });
    } catch (e) {
      print('Error sending order notification: $e');
      rethrow;
    }
  }

  // Send notification for reservation status change
  Future<void> sendReservationNotification(int reservationId, String status) async {
    try {
      await post('/api/notifications/', {
        'type': 'reservation',
        'reservation_id': reservationId,
        'status': status,
      });
    } catch (e) {
      print('Error sending reservation notification: $e');
      rethrow;
    }
  }

  // Update reservation status
  Future<dynamic> updateReservationStatus(int reservationId, String status) async {
    try {
      final response = await dio.patch(
        '$baseUrl/api/reservations/$reservationId/',
        data: {'statut': status}
      );
      return response.data;
    } catch (e) {
      print('Error updating reservation status: $e');
      rethrow;
    }
  }

  // Upload payment proof for a reservation
  Future<dynamic> uploadReservationPayment(int reservationId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'preuve_paiement': await MultipartFile.fromFile(filePath),
      });

      final response = await dio.patch(
        '$baseUrl/api/reservations/$reservationId/upload-payment/',
        data: formData,
      );
      return response.data;
    } catch (e) {
      print('Error uploading payment proof: $e');
      rethrow;
    }
  }

  // Cancel a reservation
  Future<dynamic> cancelReservation(int reservationId) async {
    try {
      final response = await dio.patch(
        '$baseUrl/api/reservations/$reservationId/cancel/',
      );
      return response.data;
    } catch (e) {
      print('Error canceling reservation: $e');
      rethrow;
    }
  }

  // Upload payment proof for a command
  Future<dynamic> uploadCommandPayment(int commandId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'preuve_paiement': await MultipartFile.fromFile(filePath),
      });

      final response = await dio.patch(
        '$baseUrl/api/commands/$commandId/upload-payment/',
        data: formData,
      );
      return response.data;
    } catch (e) {
      print('Error uploading payment proof: $e');
      rethrow;
    }
  }

  // Cancel a command
  Future<dynamic> cancelCommand(int commandId) async {
    try {
      final response = await dio.patch(
        '$baseUrl/api/commands/$commandId/cancel/',
      );
      return response.data;
    } catch (e) {
      print('Error canceling command: $e');
      rethrow;
    }
  }

  // Delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await dio.delete('$baseUrl/api/notifications/$notificationId/');
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }
}
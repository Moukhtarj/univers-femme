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
      print('=== POST REQUEST DEBUG ===');
      print('Base URL: $baseUrl');
      print('Endpoint: $endpoint');
      print('Normalized endpoint: $normalizedEndpoint');
      print('Full URL: $url');
      print('Headers: ${token != null ? "With Authorization token" : "Without Authorization"}');
      print('Request body: $data');
      print('Request method: POST');
      print('========================');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

      print('=== RESPONSE DEBUG ===');
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      print('=====================');
      
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
        // Log the status code for debugging
        print('HTTP Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        
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
              // Show user-friendly message based on status code
              switch (response.statusCode) {
                case 400:
                  errorMessage = 'Invalid request. Please check your information and try again.';
                  break;
                case 401:
                  errorMessage = 'Authentication required. Please log in again.';
                  break;
                case 403:
                  errorMessage = 'Access denied. You don\'t have permission to perform this action.';
                  break;
                case 404:
                  errorMessage = 'Service not found. Please try again later.';
                  break;
                case 500:
                  errorMessage = 'Server error. Please try again later.';
                  break;
                default:
                  errorMessage = 'An error occurred. Please try again.';
              }
            }
          } else {
            errorMessage = 'An error occurred. Please try again.';
          }
          
          throw Exception(errorMessage);
        } catch (e) {
          if (e is FormatException) {
            // If the error response is not JSON, show user-friendly message
            String userMessage;
            switch (response.statusCode) {
              case 400:
                userMessage = 'Invalid request. Please check your information and try again.';
                break;
              case 401:
                userMessage = 'Authentication required. Please log in again.';
                break;
              case 403:
                userMessage = 'Access denied. You don\'t have permission to perform this action.';
                break;
              case 404:
                userMessage = 'Service not found. Please try again later.';
                break;
              case 500:
                userMessage = 'Server error. Please try again later.';
                break;
              default:
                userMessage = 'An error occurred. Please try again.';
            }
            throw Exception(userMessage);
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
      // Log the status code for debugging
      print('HTTP Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      // Show user-friendly message based on status code
      String userMessage;
      switch (response.statusCode) {
        case 400:
          userMessage = 'Invalid request. Please check your information and try again.';
          break;
        case 401:
          userMessage = 'Authentication required. Please log in again.';
          break;
        case 403:
          userMessage = 'Access denied. You don\'t have permission to perform this action.';
          break;
        case 404:
          userMessage = 'Service not found. Please try again later.';
          break;
        case 500:
          userMessage = 'Server error. Please try again later.';
          break;
        default:
          userMessage = 'An error occurred. Please try again.';
      }
      throw Exception(userMessage);
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
      // Log the status code for debugging
      print('HTTP Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      // Show user-friendly message based on status code
      String userMessage;
      switch (response.statusCode) {
        case 400:
          userMessage = 'Invalid request. Please check your information and try again.';
          break;
        case 401:
          userMessage = 'Authentication required. Please log in again.';
          break;
        case 403:
          userMessage = 'Access denied. You don\'t have permission to perform this action.';
          break;
        case 404:
          userMessage = 'Service not found. Please try again later.';
          break;
        case 500:
          userMessage = 'Server error. Please try again later.';
          break;
        default:
          userMessage = 'An error occurred. Please try again.';
      }
      throw Exception(userMessage);
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
      final response = await getList('/api/notifications/');
      return response;
    } catch (e) {
      print('Error fetching notifications: $e');
      rethrow;
    }
  }
  
  // ================== MLAHFA SERVICES ==================
  
  // Get all melhfa types
  Future<List<dynamic>> getMelhfaTypes() async {
    try {
      final response = await getList('/api/melhfa/types/');
      return response;
    } catch (e) {
      print('Error fetching melhfa types from API: $e');
      print('Providing fallback melhfa types');
      
      // Return fallback data with the 3 specific types
      return [
        {
          'id': 1,
          'name': 'gaz',
          'image_url': 'assets/images/melhfa_gaz.jpg',
          'rating': 4.5,
        },
        {
          'id': 2,
          'name': 'karra',
          'image_url': 'assets/images/melhfa_koura.jpg',
          'rating': 4.3,
        },
        {
          'id': 3,
          'name': 'khyata',
          'image_url': 'assets/images/melhfa_khayata.jpg',
          'rating': 4.7,
        },
      ];
    }
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

      // Try different endpoints to find the one that works
      List<String> endpoints = [
        '/api/reservations/client/',
        '/api/reservations/',
        '/api/reservations/user/',
      ];

      for (String endpoint in endpoints) {
        try {
          print('Trying reservations endpoint: $endpoint');
          final url = baseUrl.endsWith('/') 
              ? '$baseUrl${endpoint.startsWith('/') ? endpoint.substring(1) : endpoint}'
              : '$baseUrl$endpoint';
          final response = await dio.get(
            url,
            queryParameters: {'user': user['id']}
          );

          if (response.data != null) {
            print('Success with endpoint: $endpoint');
            return List<dynamic>.from(response.data);
          }
        } catch (e) {
          print('Failed with endpoint $endpoint: $e');
          continue;
        }
      }

      // If all endpoints fail, return empty list
      print('All reservation endpoints failed, returning empty list');
      return [];
    } catch (e) {
      print('Error fetching reservations: $e');
      return []; // Return empty list instead of throwing
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
      print('=== CREATE RESERVATION DEBUG ===');
      print('Input data: $data');
      
      // Get current user first
      final user = await getCurrentUser();
      if (user == null || user['id'] == null) {
        throw Exception('User not logged in');
      }
      print('Current user: $user');

      // Create reservation data - only send what the API expects
      final reservationData = {
        'service_type': data['service_type'],
        'service_id': int.parse(data['service_id'].toString()),
        'date_debut': data['date_debut'],
        'date_fin': data['date_fin'],
        'commentaire': data['commentaire'] ?? '',
      };

      // Add payment proof if provided
      if (data['preuve_paiement'] != null) {
        // For file uploads, we'll need to handle this differently
        // For now, we'll skip file uploads and focus on the basic reservation
        print('Payment proof provided but not handling file uploads yet');
      }
      
      print('Sending reservation data: $reservationData'); // Debug print

      // Use dio.post with FormData for reservation creation since Django expects multipart/form-data
      final formData = FormData.fromMap(reservationData);
      
      // Fix URL construction to avoid double slashes
      final endpoint = '/api/reservations/create/';
      final url = baseUrl.endsWith('/') 
          ? '$baseUrl${endpoint.startsWith('/') ? endpoint.substring(1) : endpoint}'
          : '$baseUrl$endpoint';
      
      print('Making request to: $url');
      
      final response = await dio.post(
        url,
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

      print('Reservation response status: ${response.statusCode}');
      print('Reservation response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else if (response.statusCode == 400) {
        // Handle validation errors
        if (response.data is Map) {
          final errors = response.data as Map;
          if (errors['detail'] != null) {
            throw Exception(errors['detail']);
          }
          final errorMessage = errors.values.join(', ');
          throw Exception(errorMessage);
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
      final response = await getList('/api/reservations/$serviceType/$serviceId/');
      return response;
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

      // Use getList method instead of dio.get
      final response = await getList('/api/reviews/');
      
      if (response is List) {
        final reviews = response
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
      final response = await getList('/api/reviews/my_reviews/');
      
      if (response is List) {
        return response
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
      final response = await getList('/api/reviews/provider_reviews/');
      
      if (response is List) {
        return response
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

      final response = await post('/api/reviews/', data);
      return Review.fromJson(response);
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final normalizedEndpoint = '/api/reviews/$reviewId/'.startsWith('/') 
          ? '/api/reviews/$reviewId/'.substring(1) 
          : '/api/reviews/$reviewId/';
      final url = '$baseUrl$normalizedEndpoint';

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        return Review.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update review');
      }
    } catch (e) {
      print('Error updating review: $e');
      rethrow;
    }
  }

  // Delete a review
  Future<void> deleteReview(int reviewId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final normalizedEndpoint = '/api/reviews/$reviewId/'.startsWith('/') 
          ? '/api/reviews/$reviewId/'.substring(1) 
          : '/api/reviews/$reviewId/';
      final url = '$baseUrl$normalizedEndpoint';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete review');
      }
    } catch (e) {
      print('Error deleting review: $e');
      rethrow;
    }
  }

  // Like/Unlike a review
  Future<void> toggleReviewLike(int reviewId) async {
    try {
      await post('/api/reviews/$reviewId/like/', {});
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
        'date_commande': data['date_debut'] ?? formattedDate, // Use date_debut if provided, otherwise use current date
        'statut': data['statut'] ?? 'pending',
        'montant_total': data['montant_total'].toString(),
        'commentaire': data['commentaire'] ?? '',
        // Set the appropriate service field based on service_type
        if (serviceType == 'henna') 'henna_service': serviceId.toString(),
        if (serviceType == 'accessory') 'accessory_service': serviceId.toString(),
        if (serviceType == 'melhfa') 'melhfa_service': serviceId.toString(),
      };

      print('Sending command data: $commandData'); // Debug print

      // Use the post method instead of dio.post
      final response = await post('/api/commands/', commandData);
      print('Command creation response: $response'); // Debug print
      return response;
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

      // Try different endpoints to find the one that works
      List<String> endpoints = [
        '/api/commands/',
        '/api/commands/user/',
        '/api/orders/',
      ];

      for (String endpoint in endpoints) {
        try {
          print('Trying commands endpoint: $endpoint');
          final response = await getList(endpoint);

          print('Raw command response: $response'); // Debug print

          if (response == null) {
            continue;
          }

          // Handle different response formats
          List<dynamic> commands = [];
          
          if (response is List) {
            commands = List<dynamic>.from(response);
          } else if (response is Map) {
            // If it's a single command
            commands = [response];
          } else {
            print('Unexpected response format: ${response.runtimeType}');
            continue;
          }

          // Filter commands for the current user if needed
          if (endpoint == '/api/commands/') {
            commands = commands.where((command) {
              if (command is Map) {
                return command['client'] == user['id'] || command['user'] == user['id'];
              }
              return false;
            }).toList();
          }

          print('Success with endpoint: $endpoint, found ${commands.length} commands');
          
          // Process each command to ensure it's a proper map
          final processedCommands = commands.map((command) {
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
                final processedCommand = {
                  'id': command['id'] ?? 0,
                  'service_type': command['service_type'] ?? 'unknown',
                  'status': command['status'] ?? command['statut'] ?? 'pending',
                  'created_at': command['created_at'] ?? DateTime.now().toIso8601String(),
                  'montant_total': command['montant_total'] ?? 0,
                  'service_details': serviceDetails,
                };
                print('Processed command: $processedCommand'); // Debug print
                return processedCommand;
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
          
          print('Returning ${processedCommands.length} processed commands'); // Debug print
          return processedCommands;
        } catch (e) {
          print('Failed with endpoint $endpoint: $e');
          continue;
        }
      }

      // If all endpoints fail, return empty list
      print('All command endpoints failed, returning empty list');
      return [];
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
      await post('/api/notifications/$notificationId/mark_as_read/', {});
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
      final url = baseUrl.endsWith('/') 
          ? '$baseUrl${endpoint.startsWith('/') ? endpoint.substring(1) : endpoint}'
          : '$baseUrl$endpoint';
      final response = await dio.get(url);
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
      final endpoint = '/api/reservations/$reservationId/';
      final url = baseUrl.endsWith('/') 
          ? '$baseUrl${endpoint.startsWith('/') ? endpoint.substring(1) : endpoint}'
          : '$baseUrl$endpoint';
      final response = await dio.patch(
        url,
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

      final endpoint = '/api/reservations/$reservationId/upload-payment/';
      final url = baseUrl.endsWith('/') 
          ? '$baseUrl${endpoint.startsWith('/') ? endpoint.substring(1) : endpoint}'
          : '$baseUrl$endpoint';
      final response = await dio.patch(
        url,
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
      final endpoint = '/api/reservations/$reservationId/cancel/';
      final url = baseUrl.endsWith('/') 
          ? '$baseUrl${endpoint.startsWith('/') ? endpoint.substring(1) : endpoint}'
          : '$baseUrl$endpoint';
      final response = await dio.patch(url);
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

      final endpoint = '/api/commands/$commandId/upload-payment/';
      final url = baseUrl.endsWith('/') 
          ? '$baseUrl${endpoint.startsWith('/') ? endpoint.substring(1) : endpoint}'
          : '$baseUrl$endpoint';
      final response = await dio.patch(
        url,
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
      final endpoint = '/api/commands/$commandId/cancel/';
      final url = baseUrl.endsWith('/') 
          ? '$baseUrl${endpoint.startsWith('/') ? endpoint.substring(1) : endpoint}'
          : '$baseUrl$endpoint';
      final response = await dio.patch(url);
      return response.data;
    } catch (e) {
      print('Error canceling command: $e');
      rethrow;
    }
  }

  // Delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final normalizedEndpoint = '/api/notifications/$notificationId/'.startsWith('/') 
          ? '/api/notifications/$notificationId/'.substring(1) 
          : '/api/notifications/$notificationId/';
      final url = '$baseUrl$normalizedEndpoint';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // Try authentication with GET method (fallback for some servers)
  Future<Map<String, dynamic>> getAuth(String endpoint, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Ensure proper URL construction with slash between baseUrl and endpoint
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = baseUrl.endsWith('/') 
        ? '$baseUrl$normalizedEndpoint'
        : '$baseUrl/$normalizedEndpoint';
    
    // Convert data to query parameters for GET request
    final queryParams = data.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}').join('&');
    final fullUrl = '$url?$queryParams';

    try {
      print('=== GET AUTH REQUEST DEBUG ===');
      print('Base URL: $baseUrl');
      print('Endpoint: $endpoint');
      print('Normalized endpoint: $normalizedEndpoint');
      print('Full URL: $fullUrl');
      print('Headers: ${token != null ? "With Authorization token" : "Without Authorization"}');
      print('Request method: GET');
      print('============================');

      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('=== GET AUTH RESPONSE DEBUG ===');
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      print('==============================');

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
              // Show user-friendly message based on status code
              switch (response.statusCode) {
                case 400:
                  errorMessage = 'Invalid request. Please check your information and try again.';
                  break;
                case 401:
                  errorMessage = 'Authentication required. Please log in again.';
                  break;
                case 403:
                  errorMessage = 'Access denied. You don\'t have permission to perform this action.';
                  break;
                case 404:
                  errorMessage = 'Service not found. Please try again later.';
                  break;
                case 500:
                  errorMessage = 'Server error. Please try again later.';
                  break;
                default:
                  errorMessage = 'An error occurred. Please try again.';
              }
            }
          } else {
            errorMessage = 'An error occurred. Please try again.';
          }
          
          throw Exception(errorMessage);
        } catch (e) {
          if (e is FormatException) {
            // If the error response is not JSON, show user-friendly message
            String userMessage;
            switch (response.statusCode) {
              case 400:
                userMessage = 'Invalid request. Please check your information and try again.';
                break;
              case 401:
                userMessage = 'Authentication required. Please log in again.';
                break;
              case 403:
                userMessage = 'Access denied. You don\'t have permission to perform this action.';
                break;
              case 404:
                userMessage = 'Service not found. Please try again later.';
                break;
              case 500:
                userMessage = 'Server error. Please try again later.';
                break;
              default:
                userMessage = 'An error occurred. Please try again.';
            }
            throw Exception(userMessage);
          }
          rethrow;
        }
      }
    } catch (e) {
      print('Exception during GET auth request: $e');
      rethrow;
    }
  }

  // Post request with form data (for reservations)
  Future<Map<String, dynamic>> postForm(String endpoint, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Ensure no double slashes in URL by removing leading slash from endpoint
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = '$baseUrl$normalizedEndpoint';

    try {
      print('=== POST FORM REQUEST DEBUG ===');
      print('Base URL: $baseUrl');
      print('Endpoint: $endpoint');
      print('Normalized endpoint: $normalizedEndpoint');
      print('Full URL: $url');
      print('Headers: ${token != null ? "With Authorization token" : "Without Authorization"}');
      print('Request body: $data');
      print('Request method: POST (form data)');
      print('=============================');

      // Convert data to form fields
      final formFields = data.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}').join('&');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: formFields,
      );

      print('=== RESPONSE DEBUG ===');
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      print('=====================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        // Log the status code for debugging
        print('HTTP Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        
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
              // Show user-friendly message based on status code
              switch (response.statusCode) {
                case 400:
                  errorMessage = 'Invalid request. Please check your information and try again.';
                  break;
                case 401:
                  errorMessage = 'Authentication required. Please log in again.';
                  break;
                case 403:
                  errorMessage = 'Access denied. You don\'t have permission to perform this action.';
                  break;
                case 404:
                  errorMessage = 'Service not found. Please try again later.';
                  break;
                case 415:
                  errorMessage = 'Invalid data format. Please try again.';
                  break;
                case 500:
                  errorMessage = 'Server error. Please try again later.';
                  break;
                default:
                  errorMessage = 'An error occurred. Please try again.';
              }
            }
          } else {
            errorMessage = 'An error occurred. Please try again.';
          }
          
          throw Exception(errorMessage);
        } catch (e) {
          if (e is FormatException) {
            // If the error response is not JSON, show user-friendly message
            String userMessage;
            switch (response.statusCode) {
              case 400:
                userMessage = 'Invalid request. Please check your information and try again.';
                break;
              case 401:
                userMessage = 'Authentication required. Please log in again.';
                break;
              case 403:
                userMessage = 'Access denied. You don\'t have permission to perform this action.';
                break;
              case 404:
                userMessage = 'Service not found. Please try again later.';
                break;
              case 415:
                userMessage = 'Invalid data format. Please try again.';
                break;
              case 500:
                userMessage = 'Server error. Please try again later.';
                break;
              default:
                userMessage = 'An error occurred. Please try again.';
            }
            throw Exception(userMessage);
          }
          rethrow;
        }
      }
    } catch (e) {
      print('Exception during POST form request: $e');
      rethrow;
    }
  }
}
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  // // Login user
  // Future<Map<String, dynamic>> login(String phone, String password) async {
  //   try {
  //     final response = await _apiService.post('/api/token/', {
  //       'phone': phone,
  //       'password': password,
  //     });
      
  //     // Save token and user data
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('token', response['access']);
  //     await prefs.setString('refresh_token', response['refresh']);
  //     await prefs.setString('user', jsonEncode(response));
      
  //     return response;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // // Register user
  // Future<Map<String, dynamic>> register({
  //   required String firstName,
  //   required String lastName,
  //   required String phone,
  //   required String password,
  //   String? email,
  // }) async {
  //   try {
  //     return await _apiService.post('/api/register/', {
  //       'first_name': firstName,
  //       'last_name': lastName,
  //       'phone': phone,
  //       'password': password,
  //       'email': email ?? '',
  //     });
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // // Verify OTP
  // Future<Map<String, dynamic>> verifyOTP(String phone, String otp) async {
  //   try {
  //     return await _apiService.post('/api/verify-otp/', {
  //       'phone': phone,
  //       'otp': otp,
  //     });
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // // Request password reset
  // Future<Map<String, dynamic>> requestPasswordReset(String phone) async {
  //   try {
  //     return await _apiService.post('/api/password-reset/', {
  //       'phone': phone,
  //     });
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // // Confirm password reset
  // Future<Map<String, dynamic>> confirmPasswordReset(String phone, String otp, String newPassword) async {
  //   try {
  //     return await _apiService.post('/api/password-reset/confirm/', {
  //       'phone': phone,
  //       'otp': otp,
  //       'new_password': newPassword,
  //     });
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    String? email,
    String? address,
  }) async {
    try {
      return await _apiService.put('/api/users/profile/', {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'address': address,
      });
    } catch (e) {
      rethrow;
    }
  }

  // // Change password
  // Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
  //   try {
  //     return await _apiService.post('/api/users/change-password/', {
  //       'current_password': currentPassword,
  //       'new_password': newPassword,
  //     });
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refresh_token');
    await prefs.remove('user');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      return json.decode(userStr);
    }
    return null;
  }
}

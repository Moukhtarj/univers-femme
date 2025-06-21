import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class FournisseurApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Dashboard Statistics
  static Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/fournisseurs/dashboard/stats/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load dashboard stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading dashboard stats: $e');
    }
  }

  // Dashboard Activities
  static Future<List<Map<String, dynamic>>> getDashboardActivities() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/fournisseurs/dashboard/activities/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? data);
      } else {
        throw Exception('Failed to load dashboard activities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading dashboard activities: $e');
    }
  }

  // Services Management
  static Future<List<Map<String, dynamic>>> getServices() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/fournisseurs/services/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? data);
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading services: $e');
    }
  }

  static Future<Map<String, dynamic>> createService(Map<String, dynamic> serviceData) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/api/fournisseurs/services/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(serviceData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create service: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating service: $e');
    }
  }

  static Future<Map<String, dynamic>> updateService(int serviceId, Map<String, dynamic> serviceData) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.put(
        Uri.parse('${Config.apiUrl}/api/fournisseurs/services/$serviceId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(serviceData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update service: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating service: $e');
    }
  }

  static Future<void> deleteService(int serviceId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.delete(
        Uri.parse('${Config.apiUrl}/api/fournisseurs/services/$serviceId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete service: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting service: $e');
    }
  }

  // Reservations Management
  static Future<List<Map<String, dynamic>>> getReservations() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/reservations/owner/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? data);
      } else {
        throw Exception('Failed to load reservations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading reservations: $e');
    }
  }

  static Future<Map<String, dynamic>> updateReservationStatus(int reservationId, String status) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.patch(
        Uri.parse('${Config.apiUrl}/api/reservations/owner/$reservationId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'statut': status}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update reservation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating reservation: $e');
    }
  }

  // Commands Management
  static Future<List<Map<String, dynamic>>> getCommands() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/commands/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? data);
      } else {
        throw Exception('Failed to load commands: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading commands: $e');
    }
  }

  static Future<Map<String, dynamic>> updateCommandStatus(int commandId, String status) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.patch(
        Uri.parse('${Config.apiUrl}/api/commands/$commandId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'statut': status}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update command: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating command: $e');
    }
  }

  // Profile Management
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/users/profile/data/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading profile: $e');
    }
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.put(
        Uri.parse('${Config.apiUrl}/api/users/profile/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  // Notifications
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/notifications/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? data);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading notifications: $e');
    }
  }

  static Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/api/notifications/$notificationId/mark_as_read/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }
}

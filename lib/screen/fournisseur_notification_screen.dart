import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class FournisseurNotificationScreen extends StatefulWidget {
  const FournisseurNotificationScreen({super.key});

  @override
  State<FournisseurNotificationScreen> createState() => _FournisseurNotificationScreenState();
}

class _FournisseurNotificationScreenState extends State<FournisseurNotificationScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _loadNotifications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/notifications/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(data['results'] ?? data);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(dynamic notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/api/notifications/$notificationId/mark_as_read/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification marked as read'),
            backgroundColor: Colors.green,
          ),
        );
        _loadNotifications();
      } else {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteNotification(dynamic notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        Uri.parse('${Config.apiUrl}/api/notifications/$notificationId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadNotifications();
      } else {
        throw Exception('Failed to delete notification: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'reservation':
        return const Color(0xFF3498DB);
      case 'order':
        return const Color(0xFFF39C12);
      case 'review':
        return const Color(0xFF27AE60);
      case 'payment':
        return const Color(0xFF8E44AD);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'reservation':
        return Icons.event_note;
      case 'order':
        return Icons.shopping_bag;
      case 'review':
        return Icons.star;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(255, 192, 203, 1),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7F8C8D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadNotifications,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(255, 192, 203, 1),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: const Color.fromRGBO(255, 192, 203, 1).withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You\'re all caught up!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    )
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return _buildNotificationCard(notification);
                        },
                      ),
                    ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final type = notification['type'] ?? 'general';
    final isRead = notification['is_read'] ?? false;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isRead ? Colors.white : const Color(0xFFF0F8FF),
          border: isRead ? null : Border.all(
            color: _getNotificationColor(type).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getNotificationColor(type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getNotificationIcon(type),
              color: _getNotificationColor(type),
              size: 20,
            ),
          ),
          title: Text(
            notification['title'] ?? 'Notification',
            style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification['message'] ?? 'No message',
                style: const TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(notification['created_at']),
                style: const TextStyle(
                  color: Color(0xFF95A5A6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              if (!isRead)
                const PopupMenuItem(
                  value: 'mark_read',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Mark as Read'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'mark_read') {
                dynamic notificationId = notification['id'];
                if (notificationId is String) {
                  notificationId = int.tryParse(notificationId) ?? 0;
                }
                _markAsRead(notificationId);
              } else if (value == 'delete') {
                dynamic notificationId = notification['id'];
                if (notificationId is String) {
                  notificationId = int.tryParse(notificationId) ?? 0;
                }
                _showDeleteConfirmation(notificationId);
              }
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(dynamic notificationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNotification(notificationId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

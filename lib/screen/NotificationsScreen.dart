// notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      // This API endpoint needs to be implemented in the backend
      // For now, we'll use a placeholder with mock data
      setState(() {
        _notifications = List.generate(5, (index) => {
          'id': index + 1,
          'title': 'Notification ${index + 1}',
          'body': 'This is a notification message',
          'created_at': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
          'is_read': false,
        });
        _isLoading = false;
      });
      
      //When the API is ready, uncomment this code:
      final notifications = await _apiService.getUserNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // This API endpoint needs to be implemented in the backend
      // When it's ready, uncomment this code:
      // await _apiService.markAllNotificationsAsRead();
      
      // For now, just update the UI
      setState(() {
        _notifications = _notifications.map((notification) => {
          ...notification,
          'is_read': true,
        }).toList();
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // This API endpoint needs to be implemented in the backend
      // When it's ready, uncomment this code:
      // await _apiService.deleteNotification(notificationId);
      
      // For now, just update the UI
      setState(() {
        _notifications.removeWhere((notification) => notification['id'] == notificationId);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_as_unread),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body:
      _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadNotifications,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          : _notifications.isEmpty
            ? const Center(
                child: Text('No notifications yet'),
              )
            : ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final DateTime createdAt = DateTime.parse(notification['created_at']);
                  final bool isRead = notification['is_read'] ?? false;
                  
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    color: isRead ? Colors.white : Colors.blue[50],
                    child: ListTile(
                      title: Text(
                        notification['title'] ?? 'Notification',
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(notification['body'] ?? ''),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('yyyy-MM-dd – kk:mm').format(createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteNotification(notification['id']);
                        },
                      ),
                      onTap: () {
                        // Mark as read when tapped
                        if (!isRead) {
                          setState(() {
                            _notifications[index] = {
                              ..._notifications[index],
                              'is_read': true,
                            };
                          });
                        }
                      },
                    ),
                  );
                },
              ),
    );
  }
}
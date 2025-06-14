import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/notification.dart' as models;
import 'history_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, Map<String, String>> translations;
  
  const NotificationsScreen({
    Key? key,
    required this.selectedLanguage,
    required this.translations,
  }) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  List<models.Notification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  String _translate(String key) {
    return widget.translations[widget.selectedLanguage]?[key] ?? 
           widget.translations['English']?[key] ?? key;
  }

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
      final response = await _apiService.getUserNotifications();
      if (response == null) {
        throw Exception('Failed to load notifications');
      }
      setState(() {
        _notifications = response.map<models.Notification>((json) => models.Notification.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(models.Notification notification) async {
    try {
      await _apiService.markNotificationAsRead(notification.id);
      setState(() {
        _notifications = _notifications.map((n) {
          if (n.id == notification.id) {
            return models.Notification(
              id: n.id,
              message: n.message,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
              data: n.data,
            );
          }
          return n;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_translate('error_marking_read'))),
      );
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'reservation':
        return Icons.calendar_today;
      case 'status_update':
        return Icons.update;
      case 'order':
        return Icons.shopping_cart;
      default:
        return Icons.notifications;
    }
  }

  void _showConfirmationDialog(BuildContext context, models.Notification notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            widget.selectedLanguage == 'Arabic' ? 'فتح الإشعار' : 'Open Notification',
            style: const TextStyle(
              color: Color(0xFF880E4F),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            widget.selectedLanguage == 'Arabic' 
                ? 'هل تريد فتح هذا الإشعار في صفحة السجل؟'
                : 'Do you want to open this notification in the history screen?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                widget.selectedLanguage == 'Arabic' ? 'إلغاء' : 'Cancel',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryScreen(
                      selectedLanguage: widget.selectedLanguage,
                      translations: widget.translations,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF06292),
              ),
              child: Text(
                widget.selectedLanguage == 'Arabic' ? 'فتح' : 'Open',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F5),
      appBar: AppBar(
        title: Text(
          widget.selectedLanguage == 'Arabic' ? 'الإشعارات' : 'Notifications',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFF8BBD0),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF8BBD0)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF8BBD0),
                        ),
                        child: Text(
                          widget.selectedLanguage == 'Arabic' ? 'حاول مرة أخرى' : 'Try Again',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Text(
                        widget.selectedLanguage == 'Arabic'
                            ? 'لا توجد إشعارات'
                            : 'No notifications',
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: const Color(0xFFF06292),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () => _showConfirmationDialog(context, notification),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8BBD0).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getNotificationIcon(notification.type),
                                        color: const Color(0xFFF06292),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notification.message,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF880E4F),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${_translate(notification.type)} • ${_formatDate(notification.createdAt)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'reservation':
        return Colors.blue;
      case 'status_update':
        return Colors.orange;
      case 'order':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (widget.selectedLanguage == 'Arabic') {
      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return 'منذ ${difference.inMinutes} دقيقة';
        }
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inDays == 1) {
        return 'الأمس';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} أيام';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } else {
      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }
} 
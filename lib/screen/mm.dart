// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../services/api_service.dart';
// import '../models/notification.dart' as models;

// class NotificationScreen extends StatefulWidget {
//   final String selectedLanguage;
//   final Map<String, Map<String, String>> translations;
  
//   const NotificationScreen({
//     super.key,
//     required this.selectedLanguage,
//     required this.translations,
//   });

//   @override
//   State<NotificationScreen> createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen> {
//   final ApiService _apiService = ApiService();
//   List<models.Notification> _notifications = [];
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     print('NotificationScreen initialized');
//     _fetchNotifications();
//   }

//   String _translate(String key) {
//     return widget.translations[widget.selectedLanguage]?[key] ?? 
//            widget.translations['English']?[key] ?? key;
//   }

//   Future<void> _fetchNotifications() async {
//     try {
//       print('Starting to fetch notifications...');
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });

//       // First try to create a test notification
//       try {
//         await _apiService.post('/api/notifications/', {
//           'title': 'Test Notification',
//           'message': 'This is a test notification',
//           'type': 'status_update'
//         });
//       } catch (e) {
//         print('Error creating test notification: $e');
//       }

//       // Then fetch notifications
//       final notifications = await _apiService.getUserNotifications();
//       print('Fetched ${notifications.length} notifications');
      
//       if (notifications.isNotEmpty) {
//         print('First notification: ${notifications.first.toJson()}');
//       }

//       setState(() {
//         _notifications = notifications;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching notifications: $e');
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _markAsRead(models.Notification notification) async {
//     if (!notification.isRead) {
//       try {
//         print('Marking notification ${notification.id} as read');
//         await _apiService.markNotificationAsRead(notification.id);
        
//         setState(() {
//           final index = _notifications.indexWhere((n) => n.id == notification.id);
//           if (index != -1) {
//             _notifications[index] = models.Notification(
//               id: notification.id,
//               title: notification.title,
//               message: notification.message,
//               type: notification.type,
//               orderId: notification.orderId,
//               reservationId: notification.reservationId,
//               isRead: true,
//               createdAt: notification.createdAt,
//               imageUrl: notification.imageUrl,
//             );
//             print('Updated notification ${notification.id} to read status');
//           }
//         });
//       } catch (e) {
//         print('Error marking notification as read: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               widget.selectedLanguage == 'Arabic' 
//                   ? 'حدث خطأ أثناء تحديث حالة الإشعار'
//                   : 'Error updating notification status'
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('Building NotificationScreen with ${_notifications.length} notifications');
//     print('Loading state: $_isLoading');
//     print('Error state: $_error');
    
//     return Scaffold(
//       backgroundColor: const Color(0xFFFDF2F5),
//       appBar: AppBar(
//         title: Text(
//           widget.selectedLanguage == 'Arabic' ? 'الإشعارات' : 'Notifications',
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         backgroundColor: const Color(0xFFF8BBD0),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         actions: [
//           // Test button to create notifications
//           IconButton(
//             icon: const Icon(Icons.add_alert),
//             onPressed: () async {
//               try {
//                 await _apiService.post('/api/notifications/test/', {});
//                 _fetchNotifications(); // Refresh the list
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(
//                       widget.selectedLanguage == 'Arabic' 
//                           ? 'تم إنشاء إشعار تجريبي'
//                           : 'Test notification created'
//                     ),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               } catch (e) {
//                 print('Error creating test notification: $e');
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(
//                       widget.selectedLanguage == 'Arabic' 
//                           ? 'حدث خطأ أثناء إنشاء الإشعار التجريبي'
//                           : 'Error creating test notification'
//                     ),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Color(0xFFF06292)))
//           : _error != null
//               ? _buildErrorView(_error!, _fetchNotifications)
//               : _notifications.isEmpty
//                   ? _buildEmptyView()
//                   : RefreshIndicator(
//                       onRefresh: _fetchNotifications,
//                       color: const Color(0xFFF06292),
//                       child: ListView.builder(
//                         padding: const EdgeInsets.all(16.0),
//                         itemCount: _notifications.length,
//                         itemBuilder: (context, index) {
//                           final notification = _notifications[index];
//                           print('Building notification item $index: ${notification.toJson()}');
//                           return _buildNotificationCard(notification);
//                         },
//                       ),
//                     ),
//     );
//   }

//   Widget _buildNotificationCard(models.Notification notification) {
//     final formattedDate = DateFormat('MMM d, yyyy – h:mm a').format(notification.createdAt);
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: () => _markAsRead(notification),
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   // Notification Icon
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.pink[50],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(
//                       _getNotificationIcon(notification.type),
//                       color: Colors.pink[300],
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
                  
//                   // Title and Date
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           notification.title,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
//                             color: const Color(0xFF880E4F),
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           formattedDate,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   // Unread indicator
//                   if (!notification.isRead)
//                     Container(
//                       width: 8,
//                       height: 8,
//                       decoration: const BoxDecoration(
//                         color: Color(0xFFF06292),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 notification.message,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[800],
//                 ),
//               ),
//               if (notification.orderId != null || notification.reservationId != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0),
//                   child: Text(
//                     notification.orderId != null 
//                         ? 'Order #${notification.orderId}'
//                         : 'Reservation #${notification.reservationId}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   IconData _getNotificationIcon(String type) {
//     switch (type.toLowerCase()) {
//       case 'order':
//         return Icons.shopping_bag;
//       case 'reservation':
//         return Icons.event;
//       case 'status_update':
//         return Icons.update;
//       default:
//         return Icons.notifications;
//     }
//   }

//   Widget _buildErrorView(String error, Future<void> Function() onRetry) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             error,
//             style: const TextStyle(color: Colors.red),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: onRetry,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFF06292),
//             ),
//             child: Text(
//               widget.selectedLanguage == 'Arabic' ? 'إعادة المحاولة' : 'Try Again',
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             widget.selectedLanguage == 'Arabic' ? 'لا توجد إشعارات' : 'No notifications',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// } 
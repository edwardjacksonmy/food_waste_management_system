// notification_provider.dart
import 'package:flutter/foundation.dart';

class NotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  // This would usually fetch notifications from an API
  // For now, we'll just simulate some notifications
  Future<void> fetchNotifications() async {
    // Simulating API call
    await Future.delayed(Duration(milliseconds: 500));

    // Sample notifications data
    _notifications = [
      {
        'id': 1,
        'message': 'New donation available near you',
        'type': 'new_donation',
        'created_at': DateTime.now().subtract(Duration(minutes: 30)),
        'is_read': false,
      },
      {
        'id': 2,
        'message': 'Your pickup request has been confirmed',
        'type': 'pickup_confirmed',
        'created_at': DateTime.now().subtract(Duration(hours: 2)),
        'is_read': false,
      },
      {
        'id': 3,
        'message': 'Your donation was picked up successfully',
        'type': 'pickup_completed',
        'created_at': DateTime.now().subtract(Duration(days: 1)),
        'is_read': true,
      },
    ];

    _countUnread();
    notifyListeners();
  }

  void markAsRead(int notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index >= 0) {
      _notifications[index]['is_read'] = true;
      _countUnread();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['is_read'] = true;
    }
    _unreadCount = 0;
    notifyListeners();
  }

  void _countUnread() {
    _unreadCount = _notifications.where((n) => n['is_read'] == false).length;
  }

  // In a real app, you would also implement methods to receive
  // push notifications from Firebase Cloud Messaging or similar
}

// notification_widget.dart
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationItem extends StatelessWidget {
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final VoidCallback onTap;

  const NotificationItem({
    Key? key,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isRead ? 1 : 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        fontWeight:
                            isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      timeago.format(createdAt),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    IconData icon;
    Color color;

    switch (type) {
      case 'new_donation':
        icon = Icons.restaurant;
        color = Colors.green;
        break;
      case 'pickup_requested':
        icon = Icons.directions_car;
        color = Colors.blue;
        break;
      case 'pickup_confirmed':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'request_rejected':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case 'donation_expired':
        icon = Icons.access_time;
        color = Colors.red;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

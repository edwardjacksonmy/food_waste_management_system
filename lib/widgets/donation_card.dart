// donation_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';

class DonationCard extends StatelessWidget {
  final FoodDonation donation;
  final VoidCallback onTap;

  const DonationCard({Key? key, required this.donation, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusIndicator(donation.status),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          donation.description ?? 'No description provided',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    Icons.restaurant,
                    '${donation.quantity} ${donation.quantityUnit}',
                  ),
                  _buildInfoItem(
                    Icons.access_time,
                    _getExpiryText(donation.expirationDate),
                  ),
                  _buildInfoItem(
                    Icons.calendar_today,
                    _getPickupWindowText(donation),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(DonationStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case DonationStatus.available:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case DonationStatus.pending:
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case DonationStatus.claimed:
        color = Colors.blue;
        icon = Icons.thumb_up;
        break;
      case DonationStatus.completed:
        color = Colors.purple;
        icon = Icons.task_alt;
        break;
      case DonationStatus.expired:
        color = Colors.red;
        icon = Icons.error;
        break;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
      ],
    );
  }

  String _getExpiryText(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Expiring';
    }
  }

  String _getPickupWindowText(FoodDonation donation) {
    final formatter = DateFormat('h:mm a');
    return '${formatter.format(donation.pickupStartTime)} - ${formatter.format(donation.pickupEndTime)}';
  }
}

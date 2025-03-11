// Import math functions for distance calculation
import 'dart:math';

// transaction.dart
enum TransactionStatus { requested, confirmed, rejected, completed, canceled }

class Transaction {
  final int? id;
  final int donationId;
  final int recipientId;
  final TransactionStatus status;
  final DateTime? scheduledPickupTime;
  final DateTime? actualPickupTime;
  final int? donorRating;
  final int? recipientRating;
  final String? donorFeedback;
  final String? recipientFeedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    this.id,
    required this.donationId,
    required this.recipientId,
    this.status = TransactionStatus.requested,
    this.scheduledPickupTime,
    this.actualPickupTime,
    this.donorRating,
    this.recipientRating,
    this.donorFeedback,
    this.recipientFeedback,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      donationId: json['donation_id'],
      recipientId: json['recipient_id'],
      status: _parseStatus(json['status']),
      scheduledPickupTime:
          json['scheduled_pickup_time'] != null
              ? DateTime.parse(json['scheduled_pickup_time'])
              : null,
      actualPickupTime:
          json['actual_pickup_time'] != null
              ? DateTime.parse(json['actual_pickup_time'])
              : null,
      donorRating: json['donor_rating'],
      recipientRating: json['recipient_rating'],
      donorFeedback: json['donor_feedback'],
      recipientFeedback: json['recipient_feedback'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static TransactionStatus _parseStatus(String status) {
    switch (status) {
      case 'requested':
        return TransactionStatus.requested;
      case 'confirmed':
        return TransactionStatus.confirmed;
      case 'rejected':
        return TransactionStatus.rejected;
      case 'completed':
        return TransactionStatus.completed;
      case 'canceled':
        return TransactionStatus.canceled;
      default:
        return TransactionStatus.requested;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donation_id': donationId,
      'recipient_id': recipientId,
      'status': status.toString().split('.').last,
      'scheduled_pickup_time': scheduledPickupTime?.toIso8601String(),
      'actual_pickup_time': actualPickupTime?.toIso8601String(),
      'donor_rating': donorRating,
      'recipient_rating': recipientRating,
      'donor_feedback': donorFeedback,
      'recipient_feedback': recipientFeedback,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

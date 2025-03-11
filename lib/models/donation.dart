// Import math functions for distance calculation
import 'dart:math';

// donation.dart
enum DonationStatus { available, pending, claimed, completed, expired }

class FoodDonation {
  final int? id;
  final int donorId;
  final String title;
  final String? description;
  final int? foodType;
  final double quantity;
  final String quantityUnit;
  final DateTime? preparedDate;
  final DateTime expirationDate;
  final String? pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final bool isDifferentLocation;
  final DateTime pickupStartTime;
  final DateTime pickupEndTime;
  final bool isPerishable;
  final String? storageRequirements;
  final DonationStatus status;
  final List<String>? images;
  final DateTime createdAt;
  final DateTime updatedAt;

  FoodDonation({
    this.id,
    required this.donorId,
    required this.title,
    this.description,
    this.foodType,
    required this.quantity,
    required this.quantityUnit,
    this.preparedDate,
    required this.expirationDate,
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.isDifferentLocation = false,
    required this.pickupStartTime,
    required this.pickupEndTime,
    this.isPerishable = true,
    this.storageRequirements,
    this.status = DonationStatus.available,
    this.images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  factory FoodDonation.fromJson(Map<String, dynamic> json) {
    return FoodDonation(
      id: json['id'],
      donorId: json['donor_id'],
      title: json['title'],
      description: json['description'],
      foodType: json['food_type'],
      quantity: json['quantity'],
      quantityUnit: json['quantity_unit'],
      preparedDate:
          json['prepared_date'] != null
              ? DateTime.parse(json['prepared_date'])
              : null,
      expirationDate: DateTime.parse(json['expiration_date']),
      pickupAddress: json['pickup_address'],
      pickupLatitude: json['pickup_latitude'],
      pickupLongitude: json['pickup_longitude'],
      isDifferentLocation: json['is_different_location'] ?? false,
      pickupStartTime: DateTime.parse(json['pickup_start_time']),
      pickupEndTime: DateTime.parse(json['pickup_end_time']),
      isPerishable: json['is_perishable'] ?? true,
      storageRequirements: json['storage_requirements'],
      status: _parseStatus(json['status']),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static DonationStatus _parseStatus(String status) {
    switch (status) {
      case 'available':
        return DonationStatus.available;
      case 'pending':
        return DonationStatus.pending;
      case 'claimed':
        return DonationStatus.claimed;
      case 'completed':
        return DonationStatus.completed;
      case 'expired':
        return DonationStatus.expired;
      default:
        return DonationStatus.available;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donor_id': donorId,
      'title': title,
      'description': description,
      'food_type': foodType,
      'quantity': quantity,
      'quantity_unit': quantityUnit,
      'prepared_date': preparedDate?.toIso8601String(),
      'expiration_date': expirationDate.toIso8601String(),
      'pickup_address': pickupAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'is_different_location': isDifferentLocation,
      'pickup_start_time': pickupStartTime.toIso8601String(),
      'pickup_end_time': pickupEndTime.toIso8601String(),
      'is_perishable': isPerishable,
      'storage_requirements': storageRequirements,
      'status': status.toString().split('.').last,
      'images': images,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Calculate if donation is nearby (within a certain radius)
  bool isNearby(double userLat, double userLng, double maxDistanceKm) {
    if (pickupLatitude == null || pickupLongitude == null) return false;

    // Simple distance calculation - in a real app, use a proper distance formula
    final distance = _calculateDistance(
      userLat,
      userLng,
      pickupLatitude!,
      pickupLongitude!,
    );

    return distance <= maxDistanceKm;
  }

  // Simplified distance calculation using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371.0; // Earth radius in kilometers
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}

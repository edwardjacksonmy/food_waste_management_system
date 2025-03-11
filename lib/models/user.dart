// user.dart
import 'package:flutter/foundation.dart';

enum UserType { donor, recipient }

class User {
  final int? id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? address;
  final double? latitude;
  final double? longitude;
  final UserType userType;
  final String? organizationName;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.address,
    this.latitude,
    this.longitude,
    required this.userType,
    this.organizationName,
    this.profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      latitude: json['location_latitude'],
      longitude: json['location_longitude'],
      userType:
          json['user_type'] == 'donor' ? UserType.donor : UserType.recipient,
      organizationName: json['organization_name'],
      profilePicture: json['profile_picture'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'address': address,
      'location_latitude': latitude,
      'location_longitude': longitude,
      'user_type': userType == UserType.donor ? 'donor' : 'recipient',
      'organization_name': organizationName,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

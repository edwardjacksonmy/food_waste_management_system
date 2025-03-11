// user_preferences.dart
class UserPreferences {
  final int? id;
  final int userId;
  final List<int>? preferredFoodCategories;
  final int? preferredPickupDistance;
  final Map<String, dynamic>? notificationSettings;

  UserPreferences({
    this.id,
    required this.userId,
    this.preferredFoodCategories,
    this.preferredPickupDistance,
    this.notificationSettings,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'],
      userId: json['user_id'],
      preferredFoodCategories:
          json['preferred_food_categories'] != null
              ? List<int>.from(json['preferred_food_categories'])
              : null,
      preferredPickupDistance: json['preferred_pickup_distance'],
      notificationSettings: json['notification_settings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'preferred_food_categories': preferredFoodCategories,
      'preferred_pickup_distance': preferredPickupDistance,
      'notification_settings': notificationSettings,
    };
  }
}

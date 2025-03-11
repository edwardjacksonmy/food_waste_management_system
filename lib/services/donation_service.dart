// donation_service.dart
import '../models/donation.dart';

class DonationService {
  final ApiService _apiService;

  DonationService(this._apiService);

  // Create a new donation
  Future<FoodDonation> createDonation(FoodDonation donation) async {
    final response = await _apiService.post('donations', donation.toJson());
    return FoodDonation.fromJson(response);
  }

  // Get donation by ID
  Future<FoodDonation> getDonation(int id) async {
    final response = await _apiService.get('donations/$id');
    return FoodDonation.fromJson(response);
  }

  // Update donation
  Future<FoodDonation> updateDonation(FoodDonation donation) async {
    if (donation.id == null) {
      throw Exception('Donation ID is required for update');
    }

    final response = await _apiService.put(
      'donations/${donation.id}',
      donation.toJson(),
    );

    return FoodDonation.fromJson(response);
  }

  // Delete donation
  Future<void> deleteDonation(int id) async {
    await _apiService.delete('donations/$id');
  }

  // Get all donations by the current user (donor)
  Future<List<FoodDonation>> getMyDonations() async {
    final response = await _apiService.get('donations/my-donations');

    return (response as List)
        .map((item) => FoodDonation.fromJson(item))
        .toList();
  }

  // Get nearby available donations (recipient)
  Future<List<FoodDonation>> getNearbyDonations(
    double latitude,
    double longitude,
    double radius,
  ) async {
    final response = await _apiService.get(
      'donations/nearby?lat=$latitude&lng=$longitude&radius=$radius',
    );

    return (response as List)
        .map((item) => FoodDonation.fromJson(item))
        .toList();
  }

  // Search donations by food type or keyword
  Future<List<FoodDonation>> searchDonations(
    String query, {
    int? foodTypeId,
  }) async {
    String endpoint = 'donations/search?q=$query';
    if (foodTypeId != null) {
      endpoint += '&food_type=$foodTypeId';
    }

    final response = await _apiService.get(endpoint);

    return (response as List)
        .map((item) => FoodDonation.fromJson(item))
        .toList();
  }
}

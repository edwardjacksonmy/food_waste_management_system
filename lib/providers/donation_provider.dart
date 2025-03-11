// donation_provider.dart
import 'package:flutter/foundation.dart';
import '../models/donation.dart';
import '../services/donation_service.dart';

class DonationProvider with ChangeNotifier {
  final DonationService _donationService;

  List<FoodDonation> _myDonations = [];
  List<FoodDonation> _nearbyDonations = [];
  FoodDonation? _selectedDonation;
  bool _isLoading = false;
  String? _error;

  // Current user ID from the Auth provider
  int? _currentUserId;

  DonationProvider(this._donationService);

  List<FoodDonation> get myDonations => _myDonations;
  List<FoodDonation> get nearbyDonations => _nearbyDonations;
  FoodDonation? get selectedDonation => _selectedDonation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get currentUserId => _currentUserId;

  set currentUserId(int? id) {
    _currentUserId = id;
    notifyListeners();
  }

  Future<void> loadMyDonations() async {
    _isLoading = true;
    notifyListeners();

    try {
      _myDonations = await _donationService.getMyDonations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<FoodDonation>> getNearbyDonations(
    double latitude,
    double longitude,
    double radius,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      _nearbyDonations = await _donationService.getNearbyDonations(
        latitude,
        longitude,
        radius,
      );
      _isLoading = false;
      notifyListeners();
      return _nearbyDonations;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> createDonation(FoodDonation donation) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newDonation = await _donationService.createDonation(donation);
      _myDonations.add(newDonation);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateDonation(FoodDonation donation) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedDonation = await _donationService.updateDonation(donation);

      // Update in my donations list
      final index = _myDonations.indexWhere((d) => d.id == donation.id);
      if (index >= 0) {
        _myDonations[index] = updatedDonation;
      }

      // Update in nearby donations list
      final nearbyIndex = _nearbyDonations.indexWhere(
        (d) => d.id == donation.id,
      );
      if (nearbyIndex >= 0) {
        _nearbyDonations[nearbyIndex] = updatedDonation;
      }

      // Update selected donation if needed
      if (_selectedDonation?.id == donation.id) {
        _selectedDonation = updatedDonation;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> getDonation(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedDonation = await _donationService.getDonation(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void selectDonation(FoodDonation donation) {
    _selectedDonation = donation;
    notifyListeners();
  }

  void clearSelectedDonation() {
    _selectedDonation = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

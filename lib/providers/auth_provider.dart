// auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isDonor => _currentUser?.userType == UserType.donor;
  bool get isRecipient => _currentUser?.userType == UserType.recipient;

  Future<bool> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isAuthenticated = await _authService.isAuthenticated();
      if (isAuthenticated) {
        _currentUser = await _authService.getCurrentUser();
      }
      _isLoading = false;
      notifyListeners();
      return isAuthenticated;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Invalid email or password';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password,
    String name,
    UserType userType,
    Map<String, dynamic> additionalData,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.register(
        email,
        password,
        name,
        userType,
        additionalData,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Registration failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

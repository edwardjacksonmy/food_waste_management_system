// auth_service.dart
import '../models/user.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  // Register a new user
  Future<User> register(
    String email,
    String password,
    String name,
    UserType userType,
    Map<String, dynamic> additionalData,
  ) async {
    final data = {
      'email': email,
      'password': password,
      'name': name,
      'user_type': userType == UserType.donor ? 'donor' : 'recipient',
      ...additionalData,
    };

    final response = await _apiService.post('auth/register', data);
    await _apiService.setAuthToken(response['token']);

    return User.fromJson(response['user']);
  }

  // Login user
  Future<User> login(String email, String password) async {
    final data = {'email': email, 'password': password};

    final response = await _apiService.post('auth/login', data);
    await _apiService.setAuthToken(response['token']);

    return User.fromJson(response['user']);
  }

  // Logout user
  Future<void> logout() async {
    await _apiService.post('auth/logout', {});
    await _apiService.clearAuthToken();
  }

  // Get current user info
  Future<User> getCurrentUser() async {
    final response = await _apiService.get('auth/user');
    return User.fromJson(response['user']);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiService.authToken;
    if (token == null) return false;

    try {
      await getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }
}

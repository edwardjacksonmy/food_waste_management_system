// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-domain.com/api';

  // Cached JWT token
  String? _authToken;

  // Get token from storage or memory
  Future<String?> get authToken async {
    if (_authToken != null) return _authToken;

    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    return _authToken;
  }

  // Set token in storage and memory
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token when logging out
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Common headers
  Future<Map<String, String>> get headers async {
    final token = await authToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // HTTP GET request
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(url, headers: await headers);

    return _handleResponse(response);
  }

  // HTTP POST request
  Future<dynamic> post(String endpoint, dynamic data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.post(
      url,
      headers: await headers,
      body: json.encode(data),
    );

    return _handleResponse(response);
  }

  // HTTP PUT request
  Future<dynamic> put(String endpoint, dynamic data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.put(
      url,
      headers: await headers,
      body: json.encode(data),
    );

    return _handleResponse(response);
  }

  // HTTP DELETE request
  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.delete(url, headers: await headers);

    return _handleResponse(response);
  }

  // Response handler
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, clear it
      clearAuthToken();
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed: ${response.statusCode} ${response.body}');
    }
  }
}

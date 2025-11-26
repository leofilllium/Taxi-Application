import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

/// Repository for authentication-related operations.
/// Wraps ApiService and manages authentication state/storage.
class AuthRepository {
  static const String _tokenKey = 'token';
  static const String _userTypeKey = 'userType';
  static const String _userIdKey = 'userId';

  /// Login with email and password.
  /// Returns a map with user data and token on success.
  /// Throws ApiException on failure.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await ApiService.post('/login', {
      'email': email,
      'password': password,
    });

    // Save authentication data
    await _saveAuthData(
      token: data['token'],
      userType: data['user']['userType'],
      userId: data['user']['id'] ?? data['userId'],
    );

    return data;
  }

  /// Register a new user (client or driver).
  /// For drivers, requires vehicle details and profile image.
  /// Returns user data and token on success.
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
    Map<String, dynamic>? vehicleData,
    XFile? profileImage,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/register');
    var request = http.MultipartRequest('POST', uri);

    // Add common fields
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['name'] = name;
    request.fields['userType'] = userType;
    request.fields['phone'] = phone;

    // Add driver-specific fields
    if (userType == 'driver') {
      if (vehicleData != null) {
        request.fields['vehicle'] = json.encode(vehicleData);
      }
      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }
    }

    // Send request
    var response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final data = json.decode(responseBody);

    if (response.statusCode == 201) {
      // Save authentication data
      await _saveAuthData(
        token: data['token'],
        userType: data['user']['userType'],
        userId: data['user']['id'] ?? data['userId'],
      );
      return data;
    } else {
      throw ApiException(
        data['error'] ?? 'Registration failed. Please check your details.',
      );
    }
  }

  /// Save authentication data to SharedPreferences.
  Future<void> _saveAuthData({
    required String token,
    required String userType,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userTypeKey, userType);
    if (userId != null) {
      await prefs.setString(_userIdKey, userId);
    }
  }

  /// Check if user is authenticated (has valid token).
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  /// Get current user type (client or driver).
  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  /// Get current user ID.
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Get current auth token.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Logout user by clearing all stored data.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

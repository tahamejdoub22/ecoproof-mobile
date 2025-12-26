import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class AuthService {
  final ApiService apiService;
  final SharedPreferences prefs;

  AuthService({
    required this.apiService,
    required this.prefs,
  });

  // Login
  Future<Map<String, dynamic>> login(String email, String password, {String? deviceFingerprint}) async {
    try {
      final response = await apiService.post(
        AppConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
          if (deviceFingerprint != null) 'deviceFingerprint': deviceFingerprint,
        },
      );

      final apiResponse = ApiResponse.fromJson(response.data, null);
      
      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data as Map<String, dynamic>;
        
        // Save tokens
        if (data['token'] != null) {
          await prefs.setString(AppConfig.tokenKey, data['token']);
        }
        if (data['refreshToken'] != null) {
          await prefs.setString(AppConfig.refreshTokenKey, data['refreshToken']);
        }
        
        // Save user data
        if (data['user'] != null) {
          final user = data['user'] as Map<String, dynamic>;
          if (user['id'] != null) {
            await prefs.setString(AppConfig.userIdKey, user['id'].toString());
          }
          if (user['email'] != null) {
            await prefs.setString(AppConfig.userEmailKey, user['email']);
          }
        }

        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
        };
      }

      return {
        'success': false,
        'message': apiResponse.error?.message ?? 'Login failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? deviceFingerprint,
  }) async {
    try {
      final data = {
        'email': email,
        'password': password,
        if (deviceFingerprint != null) 'deviceFingerprint': deviceFingerprint,
      };

      final response = await apiService.post(
        AppConfig.registerEndpoint,
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(response.data, null);

      if (apiResponse.success && apiResponse.data != null) {
        final responseData = apiResponse.data as Map<String, dynamic>;
        
        // Save tokens if provided
        if (responseData['token'] != null) {
          await prefs.setString(AppConfig.tokenKey, responseData['token']);
        }
        if (responseData['refreshToken'] != null) {
          await prefs.setString(AppConfig.refreshTokenKey, responseData['refreshToken']);
        }

        return {
          'success': true,
          'user': responseData['user'] ?? responseData,
          'message': 'Registration successful',
        };
      }

      return {
        'success': false,
        'message': apiResponse.error?.message ?? 'Registration failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await apiService.post(AppConfig.logoutEndpoint);
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      // Clear local storage
      await prefs.remove(AppConfig.tokenKey);
      await prefs.remove(AppConfig.refreshTokenKey);
      await prefs.remove(AppConfig.userIdKey);
      await prefs.remove(AppConfig.userEmailKey);
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return prefs.getString(AppConfig.tokenKey) != null;
  }

  // Get current token
  String? getToken() {
    return prefs.getString(AppConfig.tokenKey);
  }

  // Get user ID
  String? getUserId() {
    return prefs.getString(AppConfig.userIdKey);
  }

  // Get user email
  String? getUserEmail() {
    return prefs.getString(AppConfig.userEmailKey);
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = prefs.getString(AppConfig.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await apiService.post(
        AppConfig.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      final apiResponse = ApiResponse.fromJson(response.data, null);
      
      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data as Map<String, dynamic>;
        if (data['token'] != null) {
          await prefs.setString(AppConfig.tokenKey, data['token']);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get user profile
  Future<UserModel?> getProfile() async {
    try {
      final response = await apiService.get(AppConfig.profileEndpoint);
      final apiResponse = ApiResponse.fromJson(response.data, null);
      
      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}


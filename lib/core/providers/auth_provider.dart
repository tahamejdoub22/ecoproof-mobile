import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService authService;
  final ApiService apiService;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  AuthProvider({
    required this.authService,
    required this.apiService,
  }) {
    checkAuthStatus();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuthStatus() async {
    _isAuthenticated = authService.isLoggedIn();
    if (_isAuthenticated) {
      await loadUserProfile();
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await authService.login(email, password);

      if (result['success'] == true) {
        _isAuthenticated = true;
        if (result['user'] != null) {
          _user = UserModel.fromJson(result['user']);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic>? additionalData,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await authService.register(
        email: email,
        password: password,
        deviceFingerprint: additionalData?['deviceFingerprint'] as String?,
      );

      if (result['success'] == true) {
        _isAuthenticated = true;
        if (result['user'] != null) {
          _user = UserModel.fromJson(result['user']);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await authService.logout();

    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserProfile() async {
    try {
      final profile = await authService.getProfile();
      if (profile != null) {
        _user = profile;
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently or log it
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

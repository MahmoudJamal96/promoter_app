import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    // Check authentication status when provider is initialized
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = true; //await _authService.isAuthenticated();

      if (_isAuthenticated) {
        _user = await _authService.getCurrentUser();
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result['success']) {
        _user = User.fromJson(result['user']);
        _isAuthenticated = true;
        _error = null;
      } else {
        _error = result['message'];
        _isAuthenticated = false;
      }

      _isLoading = false;
      notifyListeners();
      return result['success'];
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.logout2();

      if (result) {
        _user = null;
        _isAuthenticated = false;
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

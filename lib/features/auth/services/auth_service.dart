// filepath: f:\Flutter_Projects\promoter_app\lib\features\auth\services\auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userNameKey = 'userName';
  static const String _userIdKey = 'userId';
  static const String _userEmailKey = 'userEmail';
  static const String _userImageKey = 'userImage';
  static const String _userPhoneKey = 'userPhone';
  static const String _userRoleKey = 'userRole';

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get current user information
  Future<User> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return User(
      id: prefs.getInt(_userIdKey) ?? 0,
      name: prefs.getString(_userNameKey) ?? 'User',
      email: prefs.getString(_userEmailKey) ?? '',
      image: prefs.getString(_userImageKey),
      phone: prefs.getString(_userPhoneKey),
      role: prefs.getString(_userRoleKey),
    );
  }

  // Login user and return result
  Future<Map<String, dynamic>> login(String email, String password) async {
    // This would normally connect to your backend API
    // For now, we'll use a simple email/password check
    final prefs = await SharedPreferences.getInstance();

    try {
      // Simple validation (in a real app, this would be an API call)
      if (email.isNotEmpty && password.length >= 6) {
        // Mock successful login
        final user = {
          'id': 1,
          'name': 'Test User',
          'email': email,
          'image': null,
          'phone': null,
          'role': 'user',
        };

        // Save user data
        await prefs.setBool(_isLoggedInKey, true);
        await prefs.setInt(_userIdKey, user['id'] as int);
        await prefs.setString(_userNameKey, user['name'] as String);
        await prefs.setString(_userEmailKey, user['email'] as String);
        if (user['image'] != null)
          await prefs.setString(_userImageKey, user['image'] as String);
        if (user['phone'] != null)
          await prefs.setString(_userPhoneKey, user['phone'] as String);
        if (user['role'] != null)
          await prefs.setString(_userRoleKey, user['role'] as String);

        return {
          'success': true,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid email or password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Logout user
  Future<bool> logout2() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, false);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Set login state manually
  Future<bool> setLoggedIn(bool value,
      {String? userName,
      int? userId,
      String? userEmail,
      String? userImage,
      String? userPhone,
      String? userRole}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, value);

      if (userName != null) {
        await prefs.setString(_userNameKey, userName);
      }

      if (userId != null) {
        await prefs.setInt(_userIdKey, userId);
      }

      if (userEmail != null) {
        await prefs.setString(_userEmailKey, userEmail);
      }

      if (userImage != null) {
        await prefs.setString(_userImageKey, userImage);
      }

      if (userPhone != null) {
        await prefs.setString(_userPhoneKey, userPhone);
      }

      if (userRole != null) {
        await prefs.setString(_userRoleKey, userRole);
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}

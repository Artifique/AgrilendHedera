import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulation d'API call - Remplacer par vraie API
    await Future.delayed(const Duration(seconds: 2));
    
    // Validation simple pour demo
    if (email.isNotEmpty && password.length >= 6) {
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        phone: '+1234567890',
        firstName: 'John',
        lastName: 'Doe',
        userType: _getUserTypeFromEmail(email),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: true,
      );
      
      await _saveAuthData('mock_token_${user.id}', user);
      
      return {
        'success': true,
        'user': user.toJson(),
        'token': 'mock_token_${user.id}',
      };
    }
    
    return {
      'success': false,
      'message': 'Email ou mot de passe incorrect',
    };
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String phone,
    required String firstName,
    required String lastName,
    required String userType,
    Map<String, dynamic>? metadata,
  }) async {
    // Simulation d'API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (email.isNotEmpty && password.length >= 6) {
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        userType: userType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: metadata,
      );
      
      await _saveAuthData('mock_token_${user.id}', user);
      
      return {
        'success': true,
        'user': user.toJson(),
        'token': 'mock_token_${user.id}',
      };
    }
    
    return {
      'success': false,
      'message': 'Données invalides',
    };
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<void> _saveAuthData(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  String _getUserTypeFromEmail(String email) {
    if (email.contains('farmer')) return 'farmer';

    if (email.contains('agent')) return 'agent';
    return 'farmer'; // default
  }
}
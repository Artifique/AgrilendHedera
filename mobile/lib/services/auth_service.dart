import 'dart:convert';



import 'package:agrilend/services/secure_storage_shim.dart';

import 'api_service.dart';
import '../models/user.dart'; // Corrected import path for User model

class AuthService {
  final ApiService api;
  final FlutterSecureStorage _secure;

  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';
  static const _typeKey = 'auth_token_type';
  static const _userKey = 'auth_user_json';

  AuthService(this.api) : _secure = const FlutterSecureStorage();

  /// Calls backend login and stores tokens + user info securely
  Future<void> loadToken() async {
    final token = await _secure.read(key: _accessKey);
    if (token != null) {
      api.setAuthToken(token);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await api.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });

    final body = resp.data;
    // ignore: avoid_print
    print('AuthService login raw response: $body');
    if (body is Map && body['success'] == true && body['data'] is Map) {
      final data = body['data'] as Map;
      final access =
          data['accessToken'] as String? ?? data['access_token'] as String?;
      final refresh =
          data['refreshToken'] as String? ?? data['refresh_token'] as String?;
      final type =
          data['tokenType'] as String? ?? data['token_type'] as String?;

      // store
      if (access != null) await _secure.write(key: _accessKey, value: access);
      if (refresh != null)
        await _secure.write(key: _refreshKey, value: refresh);
      if (type != null) await _secure.write(key: _typeKey, value: type);

      final userMap = {
        'userId': data['userId'] ?? data['id'],
        'email': data['email'],
        'firstName': data['firstName'],
        'lastName': data['lastName'],
        'phone': data['phone'],
        'address': data['address'],
        'hederaAccountId': data['hederaAccountId'],
        'role': data['role'] ?? data['userType'],
        'isActive': data['isActive'],
        'emailVerified': data['emailVerified'],
        'createdAt': data['createdAt'],
        'updatedAt': data['updatedAt'],
        'companyName': data['companyName'],
        'businessType': data['activityType'],
        'businessAddress': data['companyAddress'],
        'businessPhone': data['businessPhone'],
        'deliveryAddress': data['deliveryAddress'],
        'farmName': data['farmName'],
        'farmLocation': data['farmLocation'],
        'farmSize': data['farmSize'],
      }..removeWhere((k, v) => v == null);

      await _secure.write(key: _userKey, value: jsonEncode(userMap));

      // set token on ApiService
      if (access != null) api.setAuthToken(access);

      return {'success': true, 'data': userMap};
    }

    return {'success': false, 'message': body['message'] ?? 'Login failed'};
  }

  Future<Map<String, dynamic>?> loadUserData() async {
    final json = await _secure.read(key: _userKey);
    if (json == null) return null;
    return Map<String, dynamic>.from(jsonDecode(json));
  }

  Future<User?> getCurrentUser() async {
    final data = await loadUserData();
    // ignore: avoid_print
    print('AuthService getCurrentUser - loaded data: $data');
    if (data == null) return null;
    try {
      final user = User(
        id: data['userId'] is int
            ? data['userId']
            : int.tryParse('${data['userId']}'),
        email: data['email'] ?? '',
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        phone: data['phone'] ?? '',
        address: data['address'],
        hederaAccountId: data['hederaAccountId'],
        role: (data['role'] ?? data['userType'] ?? 'BUYER').toString(),
        isActive: data['isActive'],
        emailVerified: data['emailVerified'],
        createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
        updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
        companyName: data['companyName'],
        businessType: data['businessType'],
        businessAddress: data['businessAddress'],
        businessPhone: data['businessPhone'],
        deliveryAddress: data['deliveryAddress'],
        farmName: data['farmName'],
        farmLocation: data['farmLocation'],
        farmSize: data['farmSize'],
      );
      // ignore: avoid_print
      print('AuthService getCurrentUser - constructed user: ${user.toJson()}');
      return user;
    } catch (e) {
      // ignore: avoid_print
      print('AuthService getCurrentUser - error constructing user: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    final resp = await api.post('/api/auth/register', data: payload);
    final body = resp.data;

    if (body is Map && body['success'] == true && body['data'] is Map) {
      final data = body['data'] as Map;
      final access =
          data['accessToken'] as String? ?? data['access_token'] as String?;
      final refresh =
          data['refreshToken'] as String? ?? data['refresh_token'] as String?;
      final type =
          data['tokenType'] as String? ?? data['token_type'] as String?;

      if (access != null) await _secure.write(key: _accessKey, value: access);
      if (refresh != null)
        await _secure.write(key: _refreshKey, value: refresh);
      if (type != null) await _secure.write(key: _typeKey, value: type);

      final userMap = {
        'userId': data['userId'] ?? data['id'],
        'email': data['email'],
        'firstName': data['firstName'],
        'lastName': data['lastName'],
        'phone': data['phone'],
        'address': data['address'],
        'hederaAccountId': data['hederaAccountId'],
        'role': data['role'] ?? data['userType'],
        'isActive': data['isActive'],
        'emailVerified': data['emailVerified'],
        'createdAt': data['createdAt'],
        'updatedAt': data['updatedAt'],
        'companyName': data['companyName'],
        'businessType': data['activityType'],
        'businessAddress': data['companyAddress'],
        'businessPhone': data['businessPhone'],
        'deliveryAddress': data['deliveryAddress'],
        'farmName': data['farmName'],
        'farmLocation': data['farmLocation'],
        'farmSize': data['farmSize'],
      }..removeWhere((k, v) => v == null);

      await _secure.write(key: _userKey, value: jsonEncode(userMap));
      if (access != null) api.setAuthToken(access);

      return {'success': true, 'data': userMap};
    }

    return {'success': false, 'message': body['message'] ?? 'Register failed'};
  }

  Future<void> logout() async {
    await _secure.delete(key: _accessKey);
    await _secure.delete(key: _refreshKey);
    await _secure.delete(key: _typeKey);
    await _secure.delete(key: _userKey);
    api.setAuthToken(null);
  }
}

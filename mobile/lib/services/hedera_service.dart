import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart'; // Import Dio for Options

import 'package:agrilend/services/api_service.dart'; // Import ApiService

// Provider for HederaService
final hederaServiceProvider = Provider<HederaService>((ref) {
  return HederaService(ref.read(secureStorageProvider), ref.read(apiServiceProvider));
});

// Provider for FlutterSecureStorage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

class HederaService {
  final FlutterSecureStorage _secureStorage;
  final ApiService _apiService;
  static const MethodChannel _platform = MethodChannel('com.agrilend.app/hedera'); // Moved inside class
  static const String _privateKeyKey = 'hedera_private_key';
  static const String _accountIdKey = 'hedera_account_id';

  HederaService(this._secureStorage, this._apiService);

  // --- Private Key Management ---
  Future<void> savePrivateKey(String privateKey) async {
    await _secureStorage.write(key: _privateKeyKey, value: privateKey);
  }

  Future<String?> getPrivateKey() async {
    return await _secureStorage.read(key: _privateKeyKey);
  }

  Future<void> deletePrivateKey() async {
    await _secureStorage.delete(key: _privateKeyKey);
  }

  // --- Account ID Management ---
  Future<void> saveAccountId(String accountId) async {
    await _secureStorage.write(key: _accountIdKey, value: accountId);
  }

  Future<String?> getAccountId() async {
    return await _secureStorage.read(key: _accountIdKey);
  }

  Future<void> deleteAccountId() async {
    await _secureStorage.delete(key: _accountIdKey);
  }

  // --- Platform Channel Calls for Hedera Transactions ---

  /// Calls native code to sign a Hedera transaction.
  /// Returns the Base64 encoded signed transaction.
  Future<String> signHederaTransaction(String unsignedTxBase64) async {
    final privateKey = await getPrivateKey();
    if (privateKey == null) {
      throw Exception('Hedera private key not found. Please configure your Hedera account.');
    }

    try {
      final String? signedTxBase64 = await _platform.invokeMethod(
        'signHederaTransaction',
        <String, dynamic>{
          'unsignedTxBase64': unsignedTxBase64,
          'privateKey': privateKey,
        },
      );
      if (signedTxBase64 == null) {
        throw Exception('Native signing failed: returned null.');
      }
      return signedTxBase64;
    } on PlatformException catch (e) {
      throw Exception('Failed to sign transaction natively: ${e.message}');
    }
  }

  Future<String> submitSignedTransaction(String signedTransactionBase64) async {
    final response = await _apiService.post(
      '/user/hedera/submit-signed-transaction',
      data: signedTransactionBase64, // The body is directly the Base64 string
      options: Options(headers: {'Content-Type': 'text/plain'}), // Specify content type as it's a raw string
    );
    if (response.data != null && response.data['success'] == true) {
      return response.data['data']; // Return the transaction ID
    } else {
      throw Exception('Failed to submit signed transaction: ${response.data?['message'] ?? 'Unknown error'}');
    }
  }

  // You can add more Hedera-related methods here that might involve native calls
  // For example, checking account balance, transferring HBAR, etc., if they require native SDK.
}

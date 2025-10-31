import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrilend/models/buyer.dart'; // Import Buyer model
import 'package:agrilend/services/api_service.dart';

final buyerServiceProvider = Provider<BuyerService>((ref) {
  return BuyerService(ref.read(apiServiceProvider));
});

class BuyerService {
  final ApiService _apiService;

  BuyerService(this._apiService);

  Future<Buyer?> getBuyerProfile() async {
    try {
      final response = await _apiService.get('/api/buyer/profile');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final userData = response.data['data'] as Map<String, dynamic>;
        return Buyer.fromJson(userData); // Return Buyer object
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching buyer profile: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> prepareHbarDeposit(double amount) async {
    final resp = await _apiService.post('/buyer/deposit/prepare', data: {'amount': amount});
    return resp.data;
  }

  Future<void> confirmHbarDeposit(String hederaTransactionId, double hbarAmount) async {
    await _apiService.post('/buyer/deposit/confirm', data: {
      'hederaTransactionId': hederaTransactionId,
      'hbarAmount': hbarAmount,
    });
  }

  Future<Map<String, dynamic>> prepareTokenAssociation(String tokenId) async {
    final resp = await _apiService.post('/buyer/token/associate/prepare', data: {'tokenId': tokenId});
    return resp.data;
  }

  Future<Map<String, dynamic>> redeemAgriTokens(String tokenId, int amount) async {
    final resp = await _apiService.post('/buyer/redeem', data: {
      'tokenId': tokenId,
      'amount': amount,
    });
    return resp.data;
  }
}
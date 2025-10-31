import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrilend/services/offer_service.dart';
import 'package:agrilend/services/api_service.dart'; // Explicitly import apiServiceProvider

final offerServiceProvider = Provider<OfferService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return OfferService(apiService);
});
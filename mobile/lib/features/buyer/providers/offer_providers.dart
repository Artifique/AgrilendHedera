import 'package:agrilend/models/offer.dart';
import 'package:agrilend/services/api_service.dart';
import 'package:agrilend/services/offer_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final offerServiceProvider = Provider<OfferService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return OfferService(apiService);
});

final offersProvider = AsyncNotifierProvider<OffersNotifier, List<Offer>>(() {
  return OffersNotifier();
});

class OffersNotifier extends AsyncNotifier<List<Offer>> {
  late final OfferService _offerService;
  List<Offer> _originalOffers = [];

  @override
  Future<List<Offer>> build() async {
    _offerService = ref.watch(offerServiceProvider);
    _originalOffers = await _offerService.getOffers();
    return _originalOffers;
  }

  void searchOffers(String query) {
    if (query.isEmpty) {
      state = AsyncValue.data(_originalOffers);
      return;
    }
    state = AsyncValue.data(_originalOffers.where((offer) {
      final name = offer.productName.toLowerCase();
      final description = offer.productDescription.toLowerCase();
      final farmerName = offer.farmerName.toLowerCase();
      return name.contains(query.toLowerCase()) ||
             description.contains(query.toLowerCase()) ||
             farmerName.contains(query.toLowerCase());
    }).toList());
  }

  void filterByCategory(String category) {
    if (category == 'Tous') {
      state = AsyncValue.data(_originalOffers);
      return;
    }
    state = AsyncValue.data(_originalOffers.where((offer) {
      // Assuming offer has a category field, or product has one
      // For now, let's use product name as a proxy for category if no direct category field in Offer
      return offer.productName.toLowerCase().contains(category.toLowerCase());
    }).toList());
  }
}

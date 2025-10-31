import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_service.dart';
import 'auth_notifier.dart';
import 'auth_service.dart';
import 'buyer_service.dart';
import 'delivery_service.dart';
import 'farmer_service.dart';
import 'notification_service.dart';
import 'offer_service.dart';
import 'order_service.dart';
import 'product_service.dart';
import 'transaction_service.dart';
import 'user_service.dart';

// Export notifier so feature code can reference AuthState/AuthNotifier types
export 'auth_notifier.dart';

final authServiceProvider =
    Provider<AuthService>((ref) => AuthService(ref.read(apiServiceProvider)));

final productServiceProvider = Provider<ProductService>(
    (ref) => ProductService(ref.read(apiServiceProvider)));
final offerServiceProvider =
    Provider<OfferService>((ref) => OfferService(ref.read(apiServiceProvider)));
final userServiceProvider =
    Provider<UserService>((ref) => UserService(ref.read(apiServiceProvider)));
final farmerServiceProvider = Provider<FarmerService>(
    (ref) => FarmerService(ref.read(apiServiceProvider)));
final buyerServiceProvider =
    Provider<BuyerService>((ref) => BuyerService(ref.read(apiServiceProvider)));
final orderServiceProvider =
    Provider<OrderService>((ref) => OrderService(ref.read(apiServiceProvider)));
final transactionServiceProvider = Provider<TransactionService>(
    (ref) => TransactionService(ref.read(apiServiceProvider)));
final notificationServiceProvider = Provider<NotificationService>(
    (ref) => NotificationService(ref.read(apiServiceProvider)));
final deliveryServiceProvider = Provider<DeliveryService>(
    (ref) => DeliveryService(ref.read(apiServiceProvider)));

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  final buyerService = ref.read(buyerServiceProvider);
  final farmerService = ref.read(farmerServiceProvider); // New
  return AuthNotifier(authService, buyerService, farmerService); // New
});

// Backwards-compatible alias
final authProvider = authNotifierProvider;

// Provider for GoRouter's refreshListenable
final goRouterNotifier = StreamProvider<bool>((ref) {
  final controller = StreamController<bool>();
  ref.listen<AuthState>(authNotifierProvider, (previous, next) {
    if (previous?.isAuthenticated != next.isAuthenticated) {
      controller.add(next.isAuthenticated);
    }
  }, fireImmediately: true); // Fire immediately to get initial state
  return controller.stream;
});

import 'package:agrilend/models/order.dart';
import 'package:agrilend/services/api_service.dart';
import 'package:agrilend/services/order_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return OrderService(apiService);
});

final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrders();
});

import 'package:agrilend/models/order.dart';
import 'package:agrilend/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.read(apiServiceProvider));
});

class OrderService {
  final ApiService _apiService;

  OrderService(this._apiService);

  Future<List<Order>> getOrders() async {
    try {
      final response = await _apiService.get('/api/buyer/orders');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> ordersData = response.data['data'];
        return ordersData.map((json) => Order.fromJson(json)).toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching orders: $e');
    }
    return [];
  }

  Future<Order> createOrder(Order order) async {
    try {
      // ignore: avoid_print
      print('OrderService.createOrder - Request Data: ${order.toJson()}');
      final response = await _apiService.post(
        '/api/buyer/orders',
        data: order.toJson(),
      );
      // ignore: avoid_print
      print('OrderService.createOrder - API Response Status: ${response.statusCode}');
      // ignore: avoid_print
      print('OrderService.createOrder - API Response Data: ${response.data}');

      if (response.statusCode == 201 && response.data['success'] == true) {
        return Order.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      // ignore: avoid_print
      print('OrderService.createOrder - Error creating order: $e');
      rethrow;
    }
  }
}
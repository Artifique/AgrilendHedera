import '../models/product.dart';
import 'api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ref.read(apiServiceProvider));
});

class ProductService {
  final ApiService api;

  ProductService(this.api);

  Future<List<Product>> fetchAll() async {
    try {
      final response = await api.get('/api/common/products');
      // ignore: avoid_print
      print('ProductService.fetchAll - API Response Status: ${response.statusCode}');
      // ignore: avoid_print
      print('ProductService.fetchAll - API Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final Map<String, dynamic>? responseData = response.data['data'];
        if (responseData != null && responseData.containsKey('content')) {
          final List<dynamic> productsData = responseData['content'];
          return productsData.map((json) => Product.fromJson(json)).toList();
        } else {
          // ignore: avoid_print
          print('ProductService.fetchAll - API Error: Missing \'data\' or \'content\' field.');
          return [];
        }
      } else {
        // ignore: avoid_print
        print('ProductService.fetchAll - API Error: ${response.data['message']}');
        return [];
      }
    } catch (e) {
      // ignore: avoid_print
      print('ProductService.fetchAll - Error fetching products: $e');
      return [];
    }
  }

  Future<Product> getById(int id) async {
    final resp = await api.get('/api/products/$id');
    return Product.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<Product> create(Product product) async {
    final resp = await api.post('/api/products', data: product.toJson());
    return Product.fromJson(Map<String, dynamic>.from(resp.data));
  }
}

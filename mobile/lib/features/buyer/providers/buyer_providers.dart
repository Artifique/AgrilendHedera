import 'package:agrilend/services/product_service.dart';
import 'package:agrilend/services/buyer_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product.dart';
import '../../../models/order.dart';
// import 'package:agrilend/models/user.dart'; // Import User model
import '../../../models/buyer.dart';
import 'package:agrilend/services/order_service.dart';

// Import the providers from their respective service files
import 'package:agrilend/services/api_service.dart'; // Import apiServiceProvider

// Provider pour les produits disponibles
final productsProvider =
    StateNotifierProvider<ProductsNotifier, List<Product>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return ProductsNotifier(productService);
});

class ProductsNotifier extends StateNotifier<List<Product>> {
  final ProductService _productService;

  ProductsNotifier(this._productService) : super([]) {
    // Charger automatiquement les produits au démarrage
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      state = await _productService.fetchAll();
    } catch (e) {
      // Gérer l'erreur, par exemple, en affichant un message ou en mettant un état d'erreur
      print('Error loading products: $e');
      state = []; // ou un état d'erreur spécifique
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      loadProducts();
      return;
    }
    
    state = state.where((product) {
      final name = product.name.toLowerCase();
      final desc = (product.description ?? '').toLowerCase();
      final cat = product.category.toLowerCase();
      return name.contains(query.toLowerCase()) ||
             desc.contains(query.toLowerCase()) ||
             cat.contains(query.toLowerCase());
    }).toList();
  }

  void filterByCategory(String category) {
    if (category == 'Tous') {
      loadProducts();
      return;
    }
    
    state = state.where((product) => product.category == category).toList();
  }

  void addProduct(Product product) {
    state = [...state, product];
  }

  void updateProduct(Product product) {
    state = state.map((p) => p.id == product.id ? product : p).toList();
  }

  void removeProduct(String productId) {
    state = state.where((p) => p.id.toString() != productId).toList();
  }
}

// Provider pour les commandes de l'acheteur
final buyerOrdersProvider = StateNotifierProvider<BuyerOrdersNotifier, List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return BuyerOrdersNotifier(orderService);
});

class BuyerOrdersNotifier extends StateNotifier<List<Order>> {
  final OrderService _orderService;

  BuyerOrdersNotifier(this._orderService) : super([]);

  Future<void> loadOrders() async {
    state = await _orderService.getOrders();
  }

  Future<void> createOrder(Order order) async {
    try {
      final createdOrder = await _orderService.createOrder(order);
      state = [createdOrder, ...state];
    } catch (e) {
      // Gérer l'erreur, par exemple, en affichant un message ou en mettant un état d'erreur
      print('Error creating order: $e');
      rethrow; // Propage l'erreur pour qu'elle soit gérée par l'UI
    }
  }

  void updateOrderStatus(int orderId, String newStatus) {
    state = state.map((order) {
      if (order.id == orderId) {
        return order.copyWith(status: newStatus);
      }
      return order;
    }).toList();
  }

  List<Order> getOrdersByStatus(String status) {
    return state.where((order) => order.status == status).toList();
  }
}



// Provider pour le profil de l'acheteur
final buyerProfileProvider = AsyncNotifierProvider<BuyerProfileNotifier, Buyer?>(() {
  return BuyerProfileNotifier();
});

class BuyerProfileNotifier extends AsyncNotifier<Buyer?> {
  @override
  Future<Buyer?> build() async {
    final buyerService = ref.watch(buyerServiceProvider);
    return buyerService.getBuyerProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    final buyerService = ref.watch(buyerServiceProvider);
    state = await AsyncValue.guard(() => buyerService.getBuyerProfile());
  }
}
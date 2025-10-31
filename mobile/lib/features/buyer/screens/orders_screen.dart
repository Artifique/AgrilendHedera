import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/buyer_providers.dart';
import '../../../models/order.dart';
import '../widgets/order_card.dart';
import '../../auth/providers/auth_provider.dart'; // Import authProvider

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(buyerOrdersProvider.notifier).loadOrders();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // S'assurer que le TabController est correctement initialisé
    if (_tabController.length != 4) {
      _tabController.dispose();
      _tabController = TabController(length: 4, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(buyerOrdersProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mes commandes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'En cours'),
            Tab(text: 'Livrées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOrdersList(orders),
            _buildOrdersList(orders
                .where((o) => ['PENDING', 'ESCROWED', 'RELEASED', 'IN_DELIVERY']
                    .contains(o.status))
                .toList()),
            _buildOrdersList(
                orders.where((o) => o.status == 'DELIVERED').toList()),
            _buildOrdersList(
                orders.where((o) => o.status == 'CANCELLED').toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune commande trouvée',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez par parcourir nos produits',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Retourner à l'accueil
                context.go('/buyer');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Parcourir les produits'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: OrderCard(
            order: order,
            onTap: () {
              // Naviguer vers les détails de la commande
              context.go('/buyer/order-details/${order.id}');
            },
          ),
        );
      },
    );
  }
}

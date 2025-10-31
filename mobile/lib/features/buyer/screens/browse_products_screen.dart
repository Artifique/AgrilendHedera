import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/buyer_providers.dart';
import '../widgets/product_card.dart'; // Assuming a ProductCard widget exists
import 'package:agrilend/models/product.dart'; // Import for Product model
import '../widgets/search_bar_widget.dart'; // Import for SearchBarWidget
import '../widgets/category_filter.dart'; // Import for CategoryFilter

class BrowseProductsScreen extends ConsumerStatefulWidget {
  const BrowseProductsScreen({super.key});

  @override
  ConsumerState<BrowseProductsScreen> createState() => _BrowseProductsScreenState();
}

class _BrowseProductsScreenState extends ConsumerState<BrowseProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(productsProvider.notifier).searchProducts(query);
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    ref.read(productsProvider.notifier).filterByCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    final List<Product> products = ref.watch(productsProvider.notifier).state;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Parcourir les produits',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CategoryFilter(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucun produit trouvé',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Essayez de modifier vos critères de recherche',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(productsProvider);
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75, // Adjust as needed
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            context.go('/buyer/product/${product.id}');
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

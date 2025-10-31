import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/buyer_providers.dart'; // New import
import '../providers/offer_providers.dart';
import '../widgets/offer_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_filter.dart';

class BuyerDashboardScreen extends ConsumerStatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  ConsumerState<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends ConsumerState<BuyerDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(offersProvider.notifier).searchOffers(query);
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    ref.read(offersProvider.notifier).filterByCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    final offers = ref.watch(offersProvider);
    final buyerProfile = ref.watch(buyerProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'AgriLend',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => context.go('/buyer/notifications'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header avec informations du profil
          buyerProfile.when(
            data: (buyerProfile) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour, ${buyerProfile?.companyName ?? 'Acheteur'}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trouvez des produits frais directement des agriculteurs',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Barre de recherche
                    SearchBarWidget(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
            loading: () => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            error: (err, stack) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          
          // Filtres par catégorie
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: CategoryFilter(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
            ),
          ),
          
          // Liste des offres
          Expanded(
            child: offers.when(
              data: (offers) => offers.isEmpty
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
                            'Aucune offre trouvée',
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
                        ref.invalidate(offersProvider);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: OfferCard(
                              offer: offer,
                              onTap: () {
                                context.go('/buyer/offer/${offer.id}');
                              },
                            ),
                          );
                        },
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

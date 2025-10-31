import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/buyer_providers.dart';
import '../../../models/product.dart';
import '../../../models/order.dart';
import '../../auth/providers/auth_provider.dart'; // Import authProvider

class OrderConfirmationScreen extends ConsumerStatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  ConsumerState<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState
    extends ConsumerState<OrderConfirmationScreen> {
  final TextEditingController _deliveryAddressController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Charger l'adresse de livraison par défaut du profil
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(buyerProfileProvider).whenData((buyerProfile) {
        if (buyerProfile?.deliveryAddress != null) {
          _deliveryAddressController.text = buyerProfile!.deliveryAddress!;
        }
      });
    });
  }

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    super.dispose();
  }

  void _confirmOrder() async {
    setState(() => _isLoading = true);

    try {
      // Récupérer les données de la commande depuis les arguments
      final Map<String, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args == null) {
        throw Exception('Données de commande manquantes');
      }

      final Product product = args['product'];
      final double quantity = args['quantity'];
      // final String notes = args['notes'] ?? ''; // not used

      final currentUserId =
          ref.read(authProvider).user?.id; // Get current user ID

      if (currentUserId == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Créer la commande
      final order = Order(
        offerId: product.id ?? 0,
        orderedQuantity: quantity,
        unitPrice: product.finalPrice ?? 0.0,
        totalAmount: quantity * (product.finalPrice ?? 0.0),
        status: 'PENDING',
        deliveryAddress: _deliveryAddressController.text,
        productUnit: product.unit,
        buyerEmail: ref.read(authProvider).user?.email ?? '',
        buyerName: ref.read(authProvider).user?.fullName ?? '',
        farmerId: product.farmerId ?? 0,
        farmerName: product.farmerName ?? '',
        productName: product.name,
        orderNumber: '',
        id: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        buyerId: currentUserId,
      );

      // Ajouter la commande
      await ref.read(buyerOrdersProvider.notifier).createOrder(order);

      // Afficher le message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Commande confirmée et fonds séquestrés avec succès!'),
            backgroundColor: Colors.green,
          ),
        );

        // Rediriger vers les commandes
        context.go('/buyer/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la confirmation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return const Scaffold(
        body: Center(
          child: Text('Erreur: Données de commande manquantes'),
        ),
      );
    }

    final Product product = args['product'];
    final double quantity = args['quantity'];
    final String notes = args['notes'] ?? '';
    final double totalPrice = quantity * (product.finalPrice ?? 0.0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Confirmation de commande',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Résumé de la commande
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Résumé de la commande',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Produit
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: product.imageList.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  product.imageList.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image,
                                        color: Colors.grey);
                                  },
                                ),
                              )
                            : const Icon(Icons.image, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Agriculteur: ${product.farmerName}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Détails de la commande
                  _buildOrderDetail('Quantité', '$quantity ${product.unit}'),
                  _buildOrderDetail('Prix unitaire', product.formattedPrice),
                  _buildOrderDetail(
                      'Total', '${totalPrice.toStringAsFixed(2)} FCFA'),

                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildOrderDetail('Notes', notes),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Adresse de livraison
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Adresse de livraison',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _deliveryAddressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre adresse de livraison...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppTheme.primaryGreen),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Informations sur le processus
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Processus de séquestre',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vos fonds seront séquestrés via la blockchain Hedera Hashgraph pour garantir la sécurité de la transaction. Ils seront automatiquement débloqués après la livraison confirmée.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Espace pour le bouton fixe
          ],
        ),
      ),

      // Bouton de confirmation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _confirmOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Confirmer la commande',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

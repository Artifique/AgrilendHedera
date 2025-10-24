import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                title: 'Créer une Offre',
                icon: Icons
                    .add_shopping_cart_rounded, // Changed icon to reflect creating an offer
                color: const Color(0xFF10B981),
                onTap: () => Future.microtask(() => GoRouter.of(context)
                    .go('/farmer/create-offer')), // Navigation absolue safe
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                title: 'Mes transactions',
                icon: Icons
                    .receipt_long_rounded, // Changed icon to reflect transactions
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Future.microtask(() =>
                      GoRouter.of(context).go('/farmer/transaction-history'));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                title: 'Gestion des stocks',
                icon: Icons.inventory_rounded,
                color: const Color(0xFF3B82F6), // Blue
                onTap: () {
                  Future.microtask(() =>
                      GoRouter.of(context).go('/farmer/stock-management'));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                title: 'Mes notifications',
                icon: Icons.notifications_rounded,
                color: const Color(0xFF8B5CF6), // Purple
                onTap: () {
                  GoRouter.of(context).go('/notifications');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(
          delay: Duration(milliseconds: 400 + (title.hashCode % 4) * 100),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
        );
  }
}

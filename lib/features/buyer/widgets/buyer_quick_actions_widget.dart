import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class BuyerQuickActionsWidget extends StatelessWidget {
  const BuyerQuickActionsWidget({super.key});

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
                title: 'Rechercher Produits',
                icon: Icons.search_rounded,
                color: const Color(0xFF3B82F6), // A blue color for buyers
                onTap: () => context.push('/buyer/products'), // Assuming a products screen for buyers
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                title: 'Mes Commandes',
                icon: Icons.shopping_bag_rounded,
                color: const Color(0xFFF59E0B), // Earthy tone for orders
                onTap: () {
                  GoRouter.of(context).go('/buyer/orders'); // Assuming an orders screen for buyers
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
                title: 'Mes Transactions',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF10B981), // Green for transactions
                onTap: () {
                  GoRouter.of(context).go('/buyer/transaction-history'); // Reusing transaction history
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                title: 'Confirmer réception',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF10B981), // Green
                onTap: () {
                  // TODO: Implement navigation to confirm reception screen
                  // GoRouter.of(context).go('/buyer/confirm-reception');
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

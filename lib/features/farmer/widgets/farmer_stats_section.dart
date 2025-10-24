import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/home/widgets/stats_card.dart'; // Reusing StatsCard

class FarmerStatsSection extends ConsumerWidget {
  const FarmerStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Fetch actual farmer stats from a provider/service
    final int activeOffers = 12;
    final int pendingOrders = 5;
    final int completedOrders = 25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques Agriculteur',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ).animate().fade().slideX(
              begin: -0.5,
              end: 0,
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
            ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Offres Actives',
                value: activeOffers.toString(),
                icon: Icons.local_offer_rounded,
                color: const Color(0xFF10B981), // Green
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatsCard(
                title: 'Commandes en Cours',
                value: pendingOrders.toString(),
                icon: Icons.shopping_bag_rounded,
                color: const Color(0xFFF59E0B), // Orange
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Commandes Terminées',
                value: completedOrders.toString(),
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF3B82F6), // Blue
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatsCard(
                title: 'Revenu Estimé',
                value: '250K FCFA',
                icon: Icons.attach_money_rounded,
                color: const Color(0xFF8B5CF6), // Purple
              ),
            ),
          ],
        ),
      ],
    );
  }
}

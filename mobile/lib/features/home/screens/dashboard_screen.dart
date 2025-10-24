import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

import '../../../core/providers/auth_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_activities.dart';

class DashboardScreen extends ConsumerWidget {
  // Change to ConsumerWidget
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    // TEMP : userType démo
    final userType = 'farmer';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, auth),
              const SizedBox(height: 24),
              _buildStatsSection(context, userType),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildRecentActivities(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic auth) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour,',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.7),
                    ),
              ),
              Text(
                auth.user?.fullName ?? 'Utilisateur',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/logo-aagri.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    ).animate().fade().slideY(
          begin: -0.5,
          end: 0,
          duration: const Duration(milliseconds: 600),
        );
  }

  Widget _buildStatsSection(BuildContext context, String? userType) {
    // Add userType
    // Dynamic stats based on userType
    List<Widget> statsCards = [];

    if (userType == 'farmer') {
      statsCards = [
        const Expanded(
          child: StatsCard(
            title: 'Offres Actives',
            value: '12',
            icon: Icons.local_offer_rounded,
            color: Color(0xFF10B981), // Green
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: StatsCard(
            title: 'Commandes en Cours',
            value: '5',
            icon: Icons.shopping_bag_rounded,
            color: Color(0xFFF59E0B), // Orange
          ),
        ),
      ];
    } else if (userType == 'buyer') {
      statsCards = [
        const Expanded(
          child: StatsCard(
            title: 'Produits Disponibles',
            value: '250',
            icon: Icons.agriculture_rounded,
            color: Color(0xFF3B82F6), // Blue
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: StatsCard(
            title: 'Mes Commandes',
            value: '8',
            icon: Icons.shopping_cart_rounded,
            color: Color(0xFF6366F1), // Purple
          ),
        ),
      ];
    } else {
      // Default or empty state
      statsCards = [
        const Expanded(
          child: StatsCard(
            title: 'Bienvenue',
            value: 'AgriLend',
            icon: Icons.info_outline_rounded,
            color: Colors.grey,
          ),
        ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques',
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
          children: statsCards,
        ),
        const SizedBox(height: 16),
        // Second row of stats, can be made dynamic as well
        // For now, keeping it simple with just one row of dynamic stats
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ).animate().fade().slideX(
              begin: -0.5,
              end: 0,
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 600),
            ),
        const SizedBox(height: 16),
        const QuickActions(),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activités récentes',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ).animate().fade().slideX(
              begin: -0.5,
              end: 0,
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 800),
            ),
        const SizedBox(height: 16),
        const RecentActivities(),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../widgets/quick_actions_widget.dart'; // Import QuickActionsWidget

class FarmerDashboardScreen extends ConsumerWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user!;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 600 ? 24 : 20,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, user.firstName ?? 'Agriculteur'),
                const SizedBox(height: 24),
                _buildWelcomeSection(context, user.firstName ?? 'Agriculteur'),
                const SizedBox(height: 24),
                _buildGlobalMarketCard(context),
                const SizedBox(height: 24),
                const QuickActionsWidget(), // Use reusable QuickActionsWidget
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String firstName) {
    return Row(
      children: [
        // Logo Agri-Lend
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.eco_rounded,
            color: Color(0xFF10B981),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Agri-Lend',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const Spacer(),
        // Notification bell
        Stack(
          children: [
            IconButton(
              onPressed: () => context.go('/farmer/notifications'),
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF6B7280),
                size: 24,
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fade().slideX(
      begin: -0.3,
      duration: const Duration(milliseconds: 600),
    );
  }
Widget _buildWelcomeSection(BuildContext context, String firstName) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Bienvenue $firstName',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
      ).animate().slideY(
        begin: -0.5,
        duration: const Duration(milliseconds: 600),
        delay: const Duration(milliseconds: 200),
      ),
      const SizedBox(height: 8),
      Text(
        'Connectez-vous au marché mondial avec vos produits',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: const Color(0xFF6B7280),
        ),
      ).animate().slideY(
        begin: -0.3,
        duration: const Duration(milliseconds: 600),
        delay: const Duration(milliseconds: 400),
      ),
    ],
  );
}


  Widget _buildGlobalMarketCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4B5563), Color(0xFF374151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.public_rounded,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Marché Mondial',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ).animate().slideX(
            begin: -0.5,
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 600),
          ),
          const SizedBox(height: 16),
          Text(
            'Vendez vos produits partout dans le monde avec la tokenisation HBAR',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFD1D5DB),
            ),
          ).animate().slideY(
            begin: 0.3,
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 800),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showContactDialog(context),
              icon: const Icon(Icons.headset_mic_rounded),
              label: const Text('Prendre Contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ).animate().scale(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 1000),
          ),
          const SizedBox(height: 20),
          _buildHowItWorksSection(context),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6B7280).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'i',
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Comment ça marche',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Contactez notre équipe pour créer votre contrat et tokeniser vos produits. Nous nous occupons de tout le processus technique.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFD1D5DB),
            ),
          ),
        ],
      ),
    ).animate().slideY(
      begin: 0.3,
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 1200),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prendre Contact'),
        content: const Text(
          'Notre équipe d\'agents vous contactera pour créer votre contrat intelligent et tokeniser vos produits.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement contact request
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demande de contact envoyée !'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
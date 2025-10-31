import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';

class AgentMainScreen extends ConsumerWidget {
  const AgentMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
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
                  _buildHeader(context, user.firstName ?? 'Agent'),
                  const SizedBox(height: 24),
                  _buildWelcomeSection(context),
                  const SizedBox(height: 24),
                  _buildStatsCards(context),
                  const SizedBox(height: 24),
                  _buildMainActionsSection(context),
                  const SizedBox(height: 24),
                  _buildRecentFarmersSection(context),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildHeader(BuildContext context, String firstName) {
    return Row(
      children: [
        // Logo Agent
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.support_agent_rounded,
            color: Color(0xFF6366F1),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Agent AgriLend',
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
              onPressed: () => context.go('/agent/notifications'),
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

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenue Agent',
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
          'Créez des contrats intelligents et gérez les pools pour les agriculteurs',
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

  Widget _buildStatsCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Agriculteurs',
            '24',
            Icons.agriculture_rounded,
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Contrats',
            '12',
            Icons.description_rounded,
            const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Pools',
            '8',
            Icons.water_drop_rounded,
            const Color(0xFF3B82F6),
          ),
        ),
      ],
    ).animate().slideY(
      begin: 0.3,
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 600),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions principales',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF374151),
          ),
        ).animate().slideY(
          begin: -0.3,
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 800),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Créer un Contrat',
                'Créer un contrat intelligent pour un agriculteur',
                Icons.description_rounded,
                const Color(0xFF6366F1),
                () => _showCreateContractDialog(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                'Créer un Pool',
                'Créer un pool de liquidité pour les agriculteurs',
                Icons.water_drop_rounded,
                const Color(0xFF3B82F6),
                () => _showCreatePoolDialog(context),
              ),
            ),
          ],
        ).animate().slideY(
          begin: 0.3,
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 1000),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Gérer les Agriculteurs',
                'Voir et gérer les agriculteurs de votre zone',
                Icons.people_rounded,
                const Color(0xFF10B981),
                () => _showManageFarmersDialog(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                'Vérification KYC',
                'Valider les documents des agriculteurs',
                Icons.verified_user_rounded,
                const Color(0xFFF59E0B),
                () => _showKycVerificationDialog(context),
              ),
            ),
          ],
        ).animate().slideY(
          begin: 0.3,
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 1200),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFarmersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agriculteurs récents',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF374151),
          ),
        ).animate().slideY(
          begin: -0.3,
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 1400),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildFarmerItem('Issa Traoré', 'Maïs - 5 hectares', 'En attente de contrat'),
              const Divider(),
              _buildFarmerItem('Fatou Diallo', 'Riz - 3 hectares', 'Contrat créé'),
              const Divider(),
              _buildFarmerItem('Moussa Camara', 'Cacao - 8 hectares', 'Pool actif'),
            ],
          ),
        ).animate().slideY(
          begin: 0.3,
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 1600),
        ),
      ],
    );
  }

  Widget _buildFarmerItem(String name, String crop, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  crop,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: _getStatusColor(status),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En attente de contrat':
        return const Color(0xFFF59E0B);
      case 'Contrat créé':
        return const Color(0xFF6366F1);
      case 'Pool actif':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.dashboard_rounded, 'Tableau de bord', true),
              _buildNavItem(context, Icons.description_rounded, 'Contrats', false),
              _buildNavItem(context, Icons.water_drop_rounded, 'Pools', false),
              _buildNavItem(context, Icons.person_rounded, 'Profil', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        // Navigation logic based on label
        switch (label) {
          case 'Tableau de bord':
            // Already on dashboard
            break;
          case 'Contrats':
            // TODO: Navigate to contracts
            break;
          case 'Pools':
            // TODO: Navigate to pools
            break;
          case 'Profil':
            context.go('/agent/profile');
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateContractDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un Contrat Intelligent'),
        content: const Text(
          'Cette fonctionnalité permettra de créer un contrat intelligent personnalisé pour un agriculteur spécifique.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité en développement'),
                  backgroundColor: Color(0xFF6366F1),
                ),
              );
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showCreatePoolDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un Pool de Liquidité'),
        content: const Text(
          'Cette fonctionnalité permettra de créer un pool de liquidité pour regrouper plusieurs agriculteurs.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité en développement'),
                  backgroundColor: Color(0xFF3B82F6),
                ),
              );
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showManageFarmersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gérer les Agriculteurs'),
        content: const Text(
          'Cette fonctionnalité permettra de voir et gérer tous les agriculteurs de votre zone d\'intervention.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showKycVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vérification KYC'),
        content: const Text(
          'Cette fonctionnalité permettra de valider les documents d\'identité des agriculteurs.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
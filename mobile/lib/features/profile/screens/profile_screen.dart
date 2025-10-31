import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui'; // Required for ImageFilter.blur, if used

import '../../auth/providers/auth_provider.dart';
import '../../../models/user.dart'; // Explicitly import User model for UserCompat extension

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isFarmer = user?.userType == 'farmer';

    if (user == null) {
      // Handle case where user is not logged in or data is not available
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [ // Added const
                    BoxShadow(
                      color: Colors.black, // Removed .withOpacity(0.05) for const
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.logout_rounded, color: Color(0xFF6366F1), size: 22),
              ),
              tooltip: 'Déconnexion',
              onPressed: () => _showLogoutDialog(context, ref),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient with blur effect
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [Color(0x3010B981), Colors.transparent],
                  radius: 0.8,
                ),
                borderRadius: BorderRadius.circular(150),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -100,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [Color(0x30059669), Colors.transparent],
                  radius: 0.7,
                ),
                borderRadius: BorderRadius.circular(125),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                
                  // Avatar and profile information
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 50),
                        padding: const EdgeInsets.fromLTRB(24, 30, 24, 80),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [const Color(0xFF10B981), const Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [ // Added const and fixed typo
                            BoxShadow(
                              color: Colors.black, // Removed .withOpacity(0.3) for const
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              user.fullName ?? 'Utilisateur',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                user.userType == 'farmer' ? 'Agriculteur' : user.userType == 'buyer' ? 'Acheteur' : 'Agent Local',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Avatar
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: const [ // Added const and fixed typo
                              BoxShadow(
                                color: Colors.black, // Removed .withOpacity(0.1) for const
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [const Color(0xFF10B981), const Color(0xFF059669)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset(
                                'assets/images/logo-aagri.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 36),
                  
                  // Contact information
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [ // Added const
                        BoxShadow(
                          color: Colors.black, // Removed .withOpacity(0.05) for const
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildContactItem(
                          context, 
                          Icons.email_rounded, 
                          'Email', 
                          user.email ?? 'N/A',
                          const Color(0xFF10B981),
                        ),
                        const Divider(height: 24),
                        _buildContactItem(
                          context, 
                          Icons.phone_rounded, 
                          'Téléphone', 
                          user.phone ?? 'N/A',
                          const Color(0xFF10B981),
                        ),
                        if (user.userType == 'farmer') ...[
                          const Divider(height: 24),
                          _buildContactItem(
                            context,
                            Icons.agriculture_rounded,
                            'Nom de la ferme',
                            user.farmName ?? 'N/A',
                            const Color(0xFF10B981),
                          ),
                          const Divider(height: 24),
                          _buildContactItem(
                            context,
                            Icons.location_on_rounded,
                            'Localisation de la ferme',
                            user.farmLocation ?? 'N/A',
                            const Color(0xFF10B981),
                          ),
                          const Divider(height: 24),
                          _buildContactItem(
                            context,
                            Icons.area_chart_rounded,
                            'Taille de la ferme',
                            user.farmSize ?? 'N/A',
                            const Color(0xFF10B981),
                          ),
                        ],
                        if (user.userType == 'buyer') ...[
                          const Divider(height: 24),
                          _buildContactItem(
                            context,
                            Icons.business_rounded,
                            'Nom de l\'entreprise',
                            user.companyName ?? 'N/A',
                            const Color(0xFF10B981),
                          ),
                          const Divider(height: 24),
                          _buildContactItem(
                            context,
                            Icons.category_rounded,
                            'Type d\'activité',
                            user.businessType ?? 'N/A',
                            const Color(0xFF10B981),
                          ),
                          const Divider(height: 24),
                          _buildContactItem(
                            context,
                            Icons.location_on_rounded,
                            'Adresse de l\'entreprise',
                            user.businessAddress ?? 'N/A',
                            const Color(0xFF10B981),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Hedera Account Section
                  _buildHederaAccountSection(context, user, isFarmer),

                  const SizedBox(height: 24),
                  
                  // Menu items with modern cards
                  _buildMenuCard(
                    context,
                    'Modifier Profil',
                    'Mettez à jour vos informations personnelles',
                    Icons.person_rounded,
                    const Color(0xFF10B981),
                    const Color(0xFFECFDF5),
                    () => context.go('/${user!.userType}/edit-profile'),
                  ),
                  
                  const SizedBox(height: 16),

                  _buildMenuCard(
                    context,
                    'Paramètres',
                    'Gérez vos préférences et notifications',
                    Icons.settings_rounded,
                    const Color(0xFF10B981),
                    const Color(0xFFECFDF5),
                    () => context.go('/${user.userType}/settings'),
                  ),
                  
                  const SizedBox(height: 16),

                  _buildMenuCard(
                    context,
                    user.userType == 'farmer' ? 'Historique des prêts' : 'Historique des Transactions',
                    user.userType == 'farmer' ? 'Consultez vos demandes et remboursements passés' : 'Consultez toutes vos transactions passées',
                    Icons.history_rounded,
                    const Color(0xFF10B981),
                    const Color(0xFFECFDF5),
                    () => context.go(user.userType == 'farmer' ? '/farmer/repayments' : '/buyer/transaction-history'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildMenuCard(
                    context,
                    'KYC & Vérification',
                    'Complétez votre profil et partagez vos documents',
                    Icons.verified_user_rounded,
                    const Color(0xFF10B981),
                    const Color(0xFFECFDF5),
                    () => GoRouter.of(context).go('/kyc-verification'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildMenuCard(
                    context,
                    'Support & Assistance',
                    'Besoin d aide ? Notre équipe est à votre écoute',
                    Icons.support_agent_rounded,
                    const Color(0xFFF59E0B),
                    const Color(0xFFFEF3C7),
                    () => context.go('/${user.userType}/support'),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHederaAccountSection(BuildContext context, User user, bool isFarmer) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, color: const Color(0xFF10B981), size: 28),
              const SizedBox(width: 16),
              Text(
                'Compte Hedera',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          if (user.hederaAccountId != null && user.hederaAccountId!.isNotEmpty) ...[
            _buildContactItem(
              context,
              Icons.credit_card_rounded,
              'ID du Compte Hedera',
              user.hederaAccountId!,
              const Color(0xFF10B981),
            ),
          ] else ...[
            Text(
              'Votre compte Hedera n\'est pas encore configuré.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              'Configurer un compte existant',
              'Associez votre ID de compte Hedera existant',
              Icons.link_rounded,
              const Color(0xFFF59E0B),
              const Color(0xFFFEF3C7),
              () => context.go('/configure-hedera-account'),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              'Créer un nouveau compte',
              'Générez un nouveau compte Hedera sécurisé',
              Icons.add_card_rounded,
              const Color(0xFF10B981),
              const Color(0xFFECFDF5),
              () => context.go('/create-hedera-account'),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildContactItem(BuildContext context, IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildMenuCard(
    BuildContext context, 
    String title, 
    String subtitle, 
    IconData icon,
    Color iconColor,
    Color bgColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [ // Added const
            BoxShadow(
              color: Colors.black, // Removed .withOpacity(0.05) for const
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF94A3B8),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerInfoItem(BuildContext context, IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Déconnexion via le provider
      await ref.read(authProvider.notifier).logout();

      // Redirection vers l'onboarding
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}

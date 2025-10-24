import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildHeader(context),
              const SizedBox(height: 60),
              Expanded(
                child: Column(
                  children: [
                    _buildUserTypeCard(
                      context,
                      title: 'Agriculteur',
                      description: 'Je souhaite obtenir un financement pour mes activités agricoles',
                      icon: Icons.agriculture_rounded,
                      color: const Color(0xFF10B981),
                      onTap: () => _navigateToRegister(context, 'farmer'),
                    ).animate().slideX(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600),
                      begin: -1,
                      end: 0,
                    ),

                    const SizedBox(height: 24),
                    _buildUserTypeCard(
                      context,
                      title: 'Agent Local',
                      description: 'Je représente Agri-lend dans ma région',
                      icon: Icons.support_agent_rounded,
                      color: const Color(0xFF6366F1),
                      onTap: () => _navigateToRegister(context, 'agent'),
                    ).animate().slideX(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 600),
                      begin: -1,
                      end: 0,
                    ),
                  ],
                ),
              ),
              _buildLoginPrompt(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF10B981),
                Color(0xFFF59E0B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.eco_rounded,
            size: 40,
            color: Colors.white,
          ),
        ).animate().scale(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
        ),
        const SizedBox(height: 24),
        Text(
          'Choisissez votre profil',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fade().slideY(
          begin: -0.3,
          duration: const Duration(milliseconds: 600),
        ),
        const SizedBox(height: 8),
        Text(
          'Sélectionnez le type de compte qui correspond à votre besoin',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ).animate().fade().slideY(
          begin: -0.3,
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildUserTypeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà un compte ? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Se connecter'),
        ),
      ],
    ).animate().fade(delay: const Duration(milliseconds: 800));
  }

  void _navigateToRegister(BuildContext context, String userType) {
    context.go('/register?userType=$userType');
  }
}
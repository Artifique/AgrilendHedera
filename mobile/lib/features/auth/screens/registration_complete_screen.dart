import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegistrationCompleteScreen extends ConsumerStatefulWidget {
  final String userType;
  
  const RegistrationCompleteScreen({
    super.key,
    required this.userType,
  });

  @override
  ConsumerState<RegistrationCompleteScreen> createState() => _RegistrationCompleteScreenState();
}

class _RegistrationCompleteScreenState extends ConsumerState<RegistrationCompleteScreen> {
  int _currentStep = 6;
  int _totalSteps = 6;

  @override
  void initState() {
    super.initState();
    // Redirection automatique après 5 secondes en mode développement
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _redirectToHome();
      }
    });
  }

  void _redirectToHome() {
    String homeRoute = _getHomeRoute(widget.userType);
    context.go(homeRoute);
  }

  String _getHomeRoute(String userType) {
    switch (userType) {
      case 'farmer':
        return '/farmer';
      case 'agent':
        return '/agent';
      case 'buyer':
        return '/buyer';
      default:
        return '/login';
    }
  }

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
              _buildProgressIndicator(),
              const SizedBox(height: 60),
              _buildSuccessAnimation(),
              const SizedBox(height: 32),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildMessage(),
              const SizedBox(height: 40),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(_totalSteps, (index) {
        final stepNumber = index + 1;
        final isCompleted = stepNumber <= _currentStep;
        
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Colors.green : Colors.grey.shade300,
                ),
                child: Center(
                  child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
              if (index < _totalSteps - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? Colors.green : Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle_rounded,
        size: 80,
        color: Colors.green,
      ),
    ).animate()
      .scale(
        delay: const Duration(milliseconds: 200),
        duration: const Duration(milliseconds: 800),
        curve: Curves.elasticOut,
      )
      .then()
      .shimmer(
        duration: const Duration(milliseconds: 1000),
        color: Colors.green.withOpacity(0.3),
      );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Félicitations !',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ).animate().slideY(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 600),
          begin: -1,
          end: 0,
        ),
        const SizedBox(height: 16),
        Text(
          'Votre compte AgriLend a été créé avec succès',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ).animate().slideY(
          delay: const Duration(milliseconds: 800),
          duration: const Duration(milliseconds: 600),
          begin: 1,
          end: 0,
        ),
      ],
    );
  }

  Widget _buildMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.blue,
            size: 32,
          ).animate().scale(
            delay: const Duration(milliseconds: 1000),
            duration: const Duration(milliseconds: 600),
          ),
          const SizedBox(height: 16),
          Text(
            'Vérification en cours',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ).animate().fade(
            delay: const Duration(milliseconds: 1200),
            duration: const Duration(milliseconds: 600),
          ),
          const SizedBox(height: 8),
          Text(
            'Votre compte sera activé dans les 24 heures après vérification de vos documents.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.blue.shade700,
            ),
            textAlign: TextAlign.center,
          ).animate().fade(
            delay: const Duration(milliseconds: 1400),
            duration: const Duration(milliseconds: 600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _redirectToHome,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Aller au tableau de bord (${widget.userType})'),
          ),
        ).animate().slideY(
          delay: const Duration(milliseconds: 1600),
          duration: const Duration(milliseconds: 600),
          begin: 1,
          end: 0,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go('/user-type'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Créer un autre compte'),
          ),
        ).animate().slideY(
          delay: const Duration(milliseconds: 1800),
          duration: const Duration(milliseconds: 600),
          begin: 1,
          end: 0,
        ),
      ],
    );
  }
}

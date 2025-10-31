import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BasicInfoScreen extends ConsumerStatefulWidget {
  final String userType;
  
  const BasicInfoScreen({
    super.key,
    required this.userType,
  });

  @override
  ConsumerState<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends ConsumerState<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  int _currentStep = 2; // Étape actuelle
  int _totalSteps = 6;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/user-type-selection'),
        ),
        title: const Text('Informations de base'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressIndicator(),
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildConfirmPasswordField(),
                const SizedBox(height: 20),
                _buildTermsCheckbox(),
                const SizedBox(height: 32),
                _buildNextButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(_totalSteps, (index) {
        final stepNumber = index + 1;
        final isCompleted = stepNumber < _currentStep;
        final isCurrent = stepNumber == _currentStep;
        
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted 
                    ? Colors.green 
                    : isCurrent 
                      ? Colors.green 
                      : Colors.grey.shade300,
                ),
                child: Center(
                  child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.grey.shade600,
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _getUserTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _getUserTypeIcon(),
            size: 40,
            color: _getUserTypeColor(),
          ),
        ).animate().scale(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 600),
        ),
        const SizedBox(height: 16),
        Text(
          'Créer votre compte ${_getUserTypeTitle()}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().slideY(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 600),
          begin: -1,
          end: 0,
        ),
        const SizedBox(height: 8),
        Text(
          'Entrez vos informations de base pour créer votre compte',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ).animate().slideY(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 600),
          begin: -1,
          end: 0,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Adresse email',
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez saisir votre email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Email invalide';
        }
        return null;
      },
    ).animate().slideX(
      delay: const Duration(milliseconds: 800),
      duration: const Duration(milliseconds: 600),
      begin: -1,
      end: 0,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez saisir un mot de passe';
        }
        if (value.length < 6) {
          return 'Minimum 4 caractères';
        }
        return null;
      },
    ).animate().slideX(
      delay: const Duration(milliseconds: 1000),
      duration: const Duration(milliseconds: 600),
      begin: 1,
      end: 0,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirmer le mot de passe',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Confirmez votre mot de passe';
        }
        if (value != _passwordController.text) {
          return 'Les mots de passe ne correspondent pas';
        }
        return null;
      },
    ).animate().slideX(
      delay: const Duration(milliseconds: 1200),
      duration: const Duration(milliseconds: 600),
      begin: -1,
      end: 0,
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'J\'accepte les '),
                TextSpan(
                  text: 'conditions d\'utilisation',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' et la '),
                TextSpan(
                  text: 'politique de confidentialité',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fade(delay: const Duration(milliseconds: 1400));
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: _acceptTerms ? _handleNext : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Continuer'),
    ).animate().scale(
      delay: const Duration(milliseconds: 1600),
      duration: const Duration(milliseconds: 600),
    );
  }

  String _getUserTypeTitle() {
    switch (widget.userType) {
      case 'farmer':
        return 'Agriculteur';
      case 'agent':
        return 'Agent Local';
      case 'buyer':
        return 'Acheteur';
      default:
        return 'Utilisateur';
    }
  }

  IconData _getUserTypeIcon() {
    switch (widget.userType) {
      case 'farmer':
        return Icons.agriculture_rounded;
      case 'agent':
        return Icons.support_agent_rounded;
      case 'buyer':
        return Icons.shopping_cart_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _getUserTypeColor() {
    switch (widget.userType) {
      case 'farmer':
        return const Color(0xFF10B981);
      case 'agent':
        return const Color(0xFF6366F1);
      case 'buyer':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;
    
    // Naviguer vers l'écran suivant avec les données
    context.go('/personal-info?userType=${widget.userType}', extra: {
      'userType': widget.userType,
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
    });
  }
}

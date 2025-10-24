import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  String _selectedUserType = AppConstants.userTypeFarmer;
  String _selectedCrop = AppConstants.cropTypes.first;

  @override
  void initState() {
    super.initState();
    // Get user type from query parameters if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouter.of(context).routeInformationProvider.value.location;
      final userType = Uri.parse(uri).queryParameters['userType'];
      if (userType != null) {
        setState(() {
          _selectedUserType = userType;
        });
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        final userType = next.user?.userType;
        switch (userType) {
          case 'farmer':
            context.go('/farmer');
            break;

          case 'agent':
            context.go('/agent');
            break;
        }
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/user-type'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildNameFields(),
                const SizedBox(height: 20),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPhoneField(),
                const SizedBox(height: 20),
                _buildUserTypeField(),
                if (_selectedUserType == AppConstants.userTypeFarmer) ...[
                  const SizedBox(height: 20),
                  _buildCropField(),
                ],
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildConfirmPasswordField(),
                const SizedBox(height: 20),
                _buildTermsCheckbox(),
                const SizedBox(height: 32),
                _buildRegisterButton(authState),
                if (authState.error != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorMessage(authState.error!),
                ],
                const SizedBox(height: 24),
                _buildLoginPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Créer un compte',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate().slideY(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 600),
          begin: -1,
          end: 0,
        ).fade(),
        const SizedBox(height: 8),
        Text(
          'Rejoignez la communauté Agri-lend',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
          ),
        ).animate().slideY(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 600),
          begin: -1,
          end: 0,
        ).fade(),
      ],
    );
  }

  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'Prénom',
              prefixIcon: Icon(Icons.person_rounded),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Requis';
              }
              return null;
            },
          ).animate().slideX(
            delay: const Duration(milliseconds: 600),
            duration: const Duration(milliseconds: 600),
            begin: -1,
            end: 0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Nom',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Requis';
              }
              return null;
            },
          ).animate().slideX(
            delay: const Duration(milliseconds: 800),
            duration: const Duration(milliseconds: 600),
            begin: 1,
            end: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email_rounded),
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
      delay: const Duration(milliseconds: 1000),
      duration: const Duration(milliseconds: 600),
      begin: -1,
      end: 0,
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Téléphone',
        prefixIcon: Icon(Icons.phone_rounded),
        hintText: '+237 6XX XXX XXX',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez saisir votre téléphone';
        }
        return null;
      },
    ).animate().slideX(
      delay: const Duration(milliseconds: 1200),
      duration: const Duration(milliseconds: 600),
      begin: 1,
      end: 0,
    );
  }

  Widget _buildUserTypeField() {
    return DropdownButtonFormField<String>(
      value: _selectedUserType,
      decoration: const InputDecoration(
        labelText: 'Type de compte',
        prefixIcon: Icon(Icons.category_rounded),
      ),
      items: [
        DropdownMenuItem(
          value: AppConstants.userTypeFarmer,
          child: const Text('Agriculteur'),
        ),

        DropdownMenuItem(
          value: AppConstants.userTypeAgent,
          child: const Text('Agent Local'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedUserType = value!;
        });
      },
    ).animate().slideX(
      delay: const Duration(milliseconds: 1400),
      duration: const Duration(milliseconds: 600),
      begin: -1,
      end: 0,
    );
  }

  Widget _buildCropField() {
    return DropdownButtonFormField<String>(
      value: _selectedCrop,
      decoration: const InputDecoration(
        labelText: 'Culture principale',
        prefixIcon: Icon(Icons.agriculture_rounded),
      ),
      items: AppConstants.cropTypes.map((crop) {
        return DropdownMenuItem(
          value: crop,
          child: Text(crop),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCrop = value!;
        });
      },
    ).animate().slideX(
      delay: const Duration(milliseconds: 1600),
      duration: const Duration(milliseconds: 600),
      begin: 1,
      end: 0,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        prefixIcon: const Icon(Icons.lock_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez saisir un mot de passe';
        }
        if (value.length < 6) {
          return 'Minimum 6 caractères';
        }
        return null;
      },
    ).animate().slideX(
      delay: const Duration(milliseconds: 1800),
      duration: const Duration(milliseconds: 600),
      begin: -1,
      end: 0,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirmer le mot de passe',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
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
      delay: const Duration(milliseconds: 2000),
      duration: const Duration(milliseconds: 600),
      begin: 1,
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
    ).animate().fade(delay: const Duration(milliseconds: 2200));
  }

  Widget _buildRegisterButton(AuthState authState) {
    return ElevatedButton(
      onPressed: authState.isLoading || !_acceptTerms ? null : _handleRegister,
      child: authState.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Créer mon compte'),
    ).animate().scale(
      delay: const Duration(milliseconds: 2400),
      duration: const Duration(milliseconds: 600),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
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
    ).animate().fade(delay: const Duration(milliseconds: 2600));
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authProvider.notifier).clearError();

    Map<String, dynamic>? metadata;
    if (_selectedUserType == AppConstants.userTypeFarmer) {
      metadata = {'primaryCrop': _selectedCrop};
    }

    final success = await ref.read(authProvider.notifier).register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      userType: _selectedUserType,
      metadata: metadata,
    );

    if (!success && mounted) {
      // L'erreur sera affichée automatiquement via le state
    }
  }
}
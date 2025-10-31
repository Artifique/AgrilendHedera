import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import 'package:agrilend/features/auth/providers/auth_provider.dart';
import '../../../services/auth_providers.dart'; // Import for userServiceProvider

class ConfigureHederaAccountScreen extends ConsumerStatefulWidget {
  const ConfigureHederaAccountScreen({super.key});

  @override
  ConsumerState<ConfigureHederaAccountScreen> createState() => _ConfigureHederaAccountScreenState();
}

class _ConfigureHederaAccountScreenState extends ConsumerState<ConfigureHederaAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hederaAccountIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _hederaAccountIdController.dispose();
    super.dispose();
  }

  Future<void> _configureAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userService = ref.read(userServiceProvider);
      final updatedUser = await userService.linkHederaAccount(_hederaAccountIdController.text.trim());

      if (mounted) {
        ref.read(authProvider.notifier).updateUserHederaAccountId(updatedUser.hederaAccountId);
        _showSuccessDialog();
      }
    } on DioException catch (e) {
      _showErrorDialog('Erreur réseau: ${e.message}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Succès'),
          content: const Text('Votre compte Hedera a été configuré avec succès.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/profile'); // Navigate back to profile
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/profile'),
        ),
        title: const Text('Configurer Compte Hedera'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _hederaAccountIdController,
                decoration: const InputDecoration(
                  labelText: 'ID du Compte Hedera',
                  hintText: 'e.g., 0.0.12345',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre ID de compte Hedera';
                  }
                  // Basic validation for Hedera account ID format (e.g., 0.0.12345)
                  if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(value)) {
                    return 'Format d\'ID de compte Hedera invalide (ex: 0.0.12345)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _configureAccount,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Configurer le compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
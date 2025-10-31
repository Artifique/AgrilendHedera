import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../services/api_service.dart';
import 'package:agrilend/features/auth/providers/auth_provider.dart';

class CreateHederaAccountScreen extends ConsumerStatefulWidget {
  const CreateHederaAccountScreen({super.key});

  @override
  ConsumerState<CreateHederaAccountScreen> createState() => _CreateHederaAccountScreenState();
}

class _CreateHederaAccountScreenState extends ConsumerState<CreateHederaAccountScreen> {
  bool _isLoading = false;
  String? _newAccountId;
  String? _newPrivateKey;

  Future<void> _createAccount() async {
    setState(() {
      _isLoading = true;
      _newAccountId = null;
      _newPrivateKey = null;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.post(
        '/api/user/create-hedera-account',
        data: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final accountId = response.data['data']['accountId'] as String?;
        final privateKey = response.data['data']['privateKey'] as String?;
        setState(() {
          _newAccountId = accountId;
          _newPrivateKey = privateKey;
        });
        if (accountId != null && privateKey != null) {
          _showSuccessDialog(accountId, privateKey);
        } else {
          _showErrorDialog('Erreur: ID de compte ou clé privée manquante dans la réponse.');
        }
      } else {
        _showErrorDialog('Erreur: ${response.statusMessage}');
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

  void _showSuccessDialog(String accountId, String privateKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Compte Hedera Créé'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Votre nouveau compte Hedera a été créé avec succès.'),
              const SizedBox(height: 10),
              const Text('Veuillez noter ces informations et les conserver en sécurité:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('ID du Compte: ', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(accountId),
              const SizedBox(height: 5),
              Text('Clé Privée: ', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(privateKey),
              const SizedBox(height: 10),
              const Text('Il est crucial de sauvegarder votre clé privée. Elle ne sera plus affichée.', style: TextStyle(color: Colors.red)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(authProvider.notifier).updateUserHederaAccountId(accountId);
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
        title: const Text('Créer Compte Hedera'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Créez un nouveau compte Hedera pour gérer vos transactions.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _createAccount,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Générer un nouveau compte Hedera'),
            ),
            if (_newAccountId != null && _newPrivateKey != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ID du Compte Hedera:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SelectableText(_newAccountId!),
                    const SizedBox(height: 10),
                    const Text('Clé Privée Hedera:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SelectableText(_newPrivateKey!),
                    const SizedBox(height: 20),
                    const Text(
                      'ATTENTION: Veuillez noter votre clé privée et la conserver en lieu sûr. Elle est nécessaire pour accéder à votre compte et ne sera plus affichée.',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

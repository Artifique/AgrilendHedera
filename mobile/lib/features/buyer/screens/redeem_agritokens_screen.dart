import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

class RedeemAgriTokensScreen extends ConsumerStatefulWidget {
  const RedeemAgriTokensScreen({super.key});

  @override
  ConsumerState<RedeemAgriTokensScreen> createState() => _RedeemAgriTokensScreenState();
}

class _RedeemAgriTokensScreenState extends ConsumerState<RedeemAgriTokensScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenIdController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String? _unsignedTx;

  @override
  void dispose() {
    _tokenIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _prepareRedemption() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _unsignedTx = null;
    });

    try {
      final apiService = ApiService();
      final requestData = {
        'tokenId': _tokenIdController.text.trim(),
        'amount': double.parse(_amountController.text.trim()),
      };
      // ignore: avoid_print
      print('RedeemAgriTokensScreen._prepareRedemption - Request Data: $requestData');
      final response = await apiService.post(
        '/api/buyer/redeem',
        data: requestData,
      );
      // ignore: avoid_print
      print('RedeemAgriTokensScreen._prepareRedemption - API Response Status: ${response.statusCode}');
      // ignore: avoid_print
      print('RedeemAgriTokensScreen._prepareRedemption - API Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _unsignedTx = response.data['data']; // Backend returns unsignedTx directly as string
        });
        _showSuccessDialog();
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rachat AgriTokens Préparé'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Transaction de rachat d\'AgriTokens préparée avec succès.'),
              const SizedBox(height: 10),
              const Text('Veuillez signer cette transaction côté client:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('Transaction non signée (Base64): ', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_unsignedTx ?? 'N/A'),
              const SizedBox(height: 10),
              const Text('Prochaine étape: Signer cette transaction avec votre clé privée Hedera et la soumettre.', style: TextStyle(color: Colors.blue)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Navigate to a screen to handle client-side signing and submission
                // For now, just go back to wallet
                context.go('/buyer/wallet');
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
          onPressed: () => context.go('/buyer/wallet'),
        ),
        title: const Text('Échanger AgriTokens'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tokenIdController,
                decoration: const InputDecoration(
                  labelText: 'ID du Token AgriToken',
                  hintText: 'e.g., 0.0.1234567',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'ID du Token';
                  }
                  // Basic validation for Token ID format (e.g., 0.0.1234567)
                  if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(value)) {
                    return 'Format d\'ID de Token invalide (ex: 0.0.1234567)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number, // Only allow numbers
                decoration: const InputDecoration(
                  labelText: 'Quantité d\'AgriTokens à échanger',
                  hintText: 'e.g., 500',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la quantité';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  if (double.parse(value) <= 0) {
                    return 'La quantité doit être supérieure à 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _prepareRedemption,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Préparer le rachat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

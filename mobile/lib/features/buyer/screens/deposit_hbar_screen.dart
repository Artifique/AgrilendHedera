import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../services/api_service.dart';
import '../../../services/hedera_service.dart';
import '../../../services/buyer_service.dart'; // Import BuyerService

class DepositHbarScreen extends ConsumerStatefulWidget {
  const DepositHbarScreen({super.key});

  @override
  ConsumerState<DepositHbarScreen> createState() => _DepositHbarScreenState();
}

class _DepositHbarScreenState extends ConsumerState<DepositHbarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String? _unsignedTxBase64;
  String? _signedTxBase64;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _prepareDeposit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _unsignedTxBase64 = null;
      _signedTxBase64 = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider); // Use injected ApiService
      final hederaService = ref.read(hederaServiceProvider);
      final buyerService = ref.read(buyerServiceProvider); // Use injected BuyerService
      final double amount = double.parse(_amountController.text.trim());

      final requestData = {'amount': amount};
      // ignore: avoid_print
      print('DepositHbarScreen._prepareDeposit - Request Data: $requestData');

      // Step 1: Prepare deposit with backend
      final prepareResponse = await buyerService.prepareHbarDeposit(amount);
      // ignore: avoid_print
      print('DepositHbarScreen._prepareDeposit - Prepare API Response Data: $prepareResponse');

      _unsignedTxBase64 = prepareResponse['unsignedTx'];
      if (_unsignedTxBase64 == null) {
        _showErrorDialog('Erreur: Transaction non signée manquante du backend.');
        return;
      }

      // Step 2: Client-side signing
      _signedTxBase64 = await hederaService.signHederaTransaction(_unsignedTxBase64!);
      // ignore: avoid_print
      print('DepositHbarScreen._prepareDeposit - Signed Tx: $_signedTxBase64');

      // Step 3: Submit signed transaction to backend
      final hederaTransactionId = await hederaService.submitSignedTransaction(_signedTxBase64!);
      // ignore: avoid_print
      print('DepositHbarScreen._prepareDeposit - Hedera Transaction ID: $hederaTransactionId');

      // Step 4: Confirm deposit with backend
      await buyerService.confirmHbarDeposit(hederaTransactionId, amount);

      _showSuccessDialog(hederaTransactionId);
    } on DioException catch (e) {
      _showErrorDialog('Erreur réseau: ${e.message}');
    } on Exception catch (e) {
      _showErrorDialog('Erreur de signature Hedera ou de confirmation: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(String hederaTransactionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dépôt HBAR Réussi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Votre dépôt HBAR a été initié avec succès sur Hedera.'),
              const SizedBox(height: 10),
              const Text('ID de Transaction Hedera:', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(hederaTransactionId),
              const SizedBox(height: 10),
              const Text('Le statut de votre dépôt sera mis à jour sous peu.', style: TextStyle(color: Colors.blue)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
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
        title: const Text('Déposer HBAR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number, // Only allow numbers
                decoration: const InputDecoration(
                  labelText: 'Montant en HBAR',
                  hintText: 'e.g., 100.0',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le montant à déposer';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Le montant doit être supérieur à 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _prepareDeposit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Préparer le dépôt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

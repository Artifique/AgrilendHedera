import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Méthode de Paiement'),
      ),
      body: const Center(
        child: Text('Payment Method Screen (Placeholder)'),
      ),
    );
  }
}

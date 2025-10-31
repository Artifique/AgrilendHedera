import 'package:flutter/material.dart';
import 'package:agrilend/models/transaction.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;
  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la Transaction'),
      ),
      body: Center(
        child: Text('Transaction Details Screen (Placeholder) for transaction ID: ${transaction.id}'),
      ),
    );
  }
}

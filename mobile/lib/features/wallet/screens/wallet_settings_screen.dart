import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WalletSettingsScreen extends ConsumerWidget {
  const WalletSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres du Portefeuille'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.credit_card),
                    title: const Text('Méthodes de Paiement'),
                    subtitle: const Text('Gérer vos cartes et comptes bancaires'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gérer les méthodes de paiement (à implémenter)')),
                      );
                      // context.push('/wallet/payment-methods');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.account_balance),
                    title: const Text('Comptes Bancaires Liés'),
                    subtitle: const Text('Ajouter ou supprimer des comptes'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gérer les comptes bancaires (à implémenter)')),
                      );
                      // context.push('/wallet/bank-accounts');
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Sécurité du Portefeuille'),
                    subtitle: const Text('Activer l\'authentification à deux facteurs'),
                    trailing: Switch(
                      value: false, // Replace with actual setting from provider
                      onChanged: (bool value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Authentification à deux facteurs: ${value ? 'Activée' : 'Désactivée'}')),
                        );
                        // Handle 2FA toggle
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.fingerprint),
                    title: const Text('Connexion Biométrique'),
                    subtitle: const Text('Utiliser l\'empreinte digitale ou la reconnaissance faciale'),
                    trailing: Switch(
                      value: true, // Replace with actual setting from provider
                      onChanged: (bool value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Connexion biométrique: ${value ? 'Activée' : 'Désactivée'}')),
                        );
                        // Handle biometric login toggle
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Historique des Transactions'),
                    subtitle: const Text('Voir toutes vos transactions passées'),
                    onTap: () {
                      context.push('/buyer/transaction-history'); // Navigate to transaction history
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

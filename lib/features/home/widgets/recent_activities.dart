import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

class RecentActivities extends ConsumerWidget {
  // Change to ConsumerWidget
  const RecentActivities({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TEMP : userType démo
    final userType = 'farmer';

    List<Map<String, dynamic>> activities = [];

    if (userType == 'farmer') {
      activities = [
        {
          'title': 'Nouvelle commande reçue',
          'date': '15/09/2025',
          'icon': Icons.shopping_bag_rounded,
          'color': Colors.green,
        },
        {
          'title': 'Offre de produit publiée',
          'date': '14/09/2025',
          'icon': Icons.local_offer_rounded,
          'color': Colors.blue,
        },
        {
          'title': 'Paiement reçu pour commande #123',
          'date': '12/09/2025',
          'icon': Icons.payments_rounded,
          'color': Colors.orange,
        },
        {
          'title': 'Profil mis à jour',
          'date': '08/09/2025',
          'icon': Icons.person,
          'color': Colors.purple,
        },
      ];
    } else if (userType == 'buyer') {
      activities = [
        {
          'title': 'Commande #456 livrée',
          'date': '16/09/2025',
          'icon': Icons.local_shipping_rounded,
          'color': Colors.green,
        },
        {
          'title': 'Nouvelle offre disponible',
          'date': '15/09/2025',
          'icon': Icons.notifications_active_rounded,
          'color': Colors.blue,
        },
        {
          'title': 'Paiement effectué pour commande #789',
          'date': '13/09/2025',
          'icon': Icons.payments_rounded,
          'color': Colors.orange,
        },
        {
          'title': 'Profil mis à jour',
          'date': '08/09/2025',
          'icon': Icons.person,
          'color': Colors.purple,
        },
      ];
    } else {
      // Default activities or empty list
      activities = [
        {
          'title': 'Bienvenue sur AgriLend',
          'date': 'Aujourd\'hui',
          'icon': Icons.info_outline,
          'color': Colors.grey,
        },
      ];
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var activity in activities)
              ListTile(
                leading: Icon(
                  activity['icon'] as IconData,
                  color: activity['color'] as Color,
                ),
                title: Text(activity['title'] as String),
                subtitle: Text(activity['date'] as String),
              ),
          ],
        ),
      ),
    );
  }
}

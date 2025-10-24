import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
    required this.color,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Simulate fetching notifications from a server
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _notifications = [
        NotificationItem(
          id: '1',
          title: 'Commande #123 Validée',
          subtitle: 'Votre commande de tomates a été validée et est en préparation.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          icon: Icons.check_circle_rounded,
          color: Colors.green,
        ),
        NotificationItem(
          id: '2',
          title: 'Début de Séquestre #456',
          subtitle: 'Le paiement pour la commande #456 est en séquestre.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          icon: Icons.lock_clock_rounded,
          color: Colors.orange,
        ),
        NotificationItem(
          id: '3',
          title: 'Livraison en cours #789',
          subtitle: 'Votre livraison de pommes est en route et arrivera bientôt.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          icon: Icons.local_shipping_rounded,
          color: Colors.blue,
        ),
        NotificationItem(
          id: '4',
          title: 'Fin de Séquestre #101',
          subtitle: 'Le paiement pour la commande #101 a été libéré.',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          icon: Icons.lock_open_rounded,
          color: Colors.green,
        ),
        NotificationItem(
          id: '5',
          title: 'Nouvelle Offre Disponible',
          subtitle: 'Un agriculteur près de chez vous a publié une nouvelle offre de maïs.',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          icon: Icons.agriculture_rounded,
          color: Colors.purple,
        ),
      ];
    });
  }

  void _dismissNotification(String id) {
    setState(() {
      _notifications.removeWhere((item) => item.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification supprimée')),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final Duration difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else {
      return 'Le ${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune notification pour le moment',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Dismissible(
                    key: Key(notification.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _dismissNotification(notification.id);
                    },
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmer la suppression'),
                            content: const Text(
                                'Êtes-vous sûr de vouloir supprimer cette notification ?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.redAccent,
                      child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
                    ),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: notification.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            notification.icon,
                            color: notification.color,
                          ),
                        ),
                        title: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        subtitle: Text(
                          notification.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        trailing: Text(
                          _formatTimestamp(notification.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        onTap: () {
                          // TODO: Handle notification tap (e.g., navigate to relevant screen)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tapped on ${notification.title}')),
                          );
                        },
                      ),
                    ).animate().fade().slideX(
                          begin: 0.5,
                          duration: const Duration(milliseconds: 300),
                          delay: Duration(milliseconds: index * 50),
                        ),
                  );
                },
              ),
      ),
    );
  }
}

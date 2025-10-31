import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Assuming a theme provider exists, e.g., in core/theme/app_theme.dart or a separate provider file
// import '../../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Example of how to watch a theme provider if it existed
    // final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
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
                    title: const Text('Thème de l\'application'),
                    subtitle: const Text('Changer entre le mode clair et sombre'),
                    trailing: DropdownButton<ThemeMode>(
                      value: ThemeMode.system, // Replace with actual themeMode from provider
                      onChanged: (ThemeMode? newValue) {
                        if (newValue != null) {
                          // ref.read(themeProvider.notifier).setThemeMode(newValue);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Thème changé en ${newValue.name}')),
                          );
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('Système'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Clair'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Sombre'),
                        ),
                      ],
                    ),
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
                    title: const Text('Notifications'),
                    subtitle: const Text('Gérer les préférences de notification'),
                    trailing: Switch(
                      value: true, // Replace with actual notification setting from provider
                      onChanged: (bool value) {
                        // Handle notification toggle
                        // ref.read(notificationSettingsProvider.notifier).toggleNotifications(value);
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Langue'),
                    subtitle: const Text('Changer la langue de l\'application'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité de changement de langue à implémenter')),
                      );
                      // context.push('/settings/language');
                    },
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
                    title: const Text('À propos'),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'AgriLend',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2023 AgriLend. Tous droits réservés.',
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Conditions d\'utilisation'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Afficher les conditions d\'utilisation')),
                      );
                      // context.push('/settings/terms');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Politique de confidentialité'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Afficher la politique de confidentialité')),
                      );
                      // context.push('/settings/privacy');
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

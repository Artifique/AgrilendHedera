import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LogoutButton extends ConsumerWidget {
  final String? text;
  final IconData? icon;
  final Color? textColor;
  final VoidCallback? onLogout;

  const LogoutButton({
    super.key,
    this.text,
    this.icon,
    this.textColor,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        icon ?? Icons.logout_outlined,
        color: textColor ?? Colors.red,
      ),
      title: Text(
        text ?? 'Déconnexion',
        style: TextStyle(
          color: textColor ?? Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () => _handleLogout(context, ref),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // Afficher une boîte de dialogue de confirmation
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Appeler la fonction de déconnexion personnalisée si fournie
      if (onLogout != null) {
        onLogout!();
      }

      // Déconnexion via le provider
      await ref.read(authProvider.notifier).logout();

      // Redirection vers l'onboarding
      if (context.mounted) {
        context.go('/onboarding');
      }
    }
  }
}

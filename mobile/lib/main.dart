import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // New import

import 'services/auth_providers.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

// auth providers are defined in services/auth_providers.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize date formatting for intl package
  await initializeDateFormatting(); // New line

  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  Animate.restartOnHotReload = true;

  // Initialize auth state by loading token from storage
  final container = ProviderContainer();
  final authNotifier = container.read(authNotifierProvider.notifier);
  await authNotifier.init();

  runApp(UncontrolledProviderScope(
      container: container, child: const AgriLendApp()));
}

class AgriLendApp extends ConsumerWidget {
  const AgriLendApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'AgriLend',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: child!,
        );
      },
    );
  }
}

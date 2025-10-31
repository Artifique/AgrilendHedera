// ...existing code...
import 'package:agrilend/models/user.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/kyc_verification_screen.dart';
import '../../features/auth/screens/registration_complete_screen.dart';
import '../../features/farmer/screens/farmer_main_screen.dart';
import '../../features/farmer/screens/create_offer_screen.dart';
import '../../features/farmer/screens/stock_management_screen.dart';

import '../../features/agent/screens/agent_main_screen.dart';
import '../../features/buyer/screens/buyer_main_screen.dart';
import '../../features/buyer/screens/product_detail_screen.dart';
import '../../features/buyer/screens/order_confirmation_screen.dart';
import '../../features/buyer/screens/order_list_screen.dart';
import '../../features/buyer/screens/offer_detail_screen.dart'; // New import
import 'package:agrilend/features/buyer/screens/payment_method_screen.dart'; // New import
import 'package:agrilend/features/transactions/screens/transaction_details_screen.dart'; // New import
import 'package:agrilend/models/transaction.dart'; // New import for extra parameter

import '../../features/transactions/screens/payment_request_screen.dart';
import '../../features/transactions/screens/transaction_history_screen.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/wallet/screens/scanner_qr_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/notification/screens/notification_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart'; // New import
import '../../features/profile/screens/settings_screen.dart'; // New import
import 'package:agrilend/features/profile/screens/support_screen.dart'; // New import
import 'package:agrilend/features/wallet/screens/receive_qr_screen.dart'; // New import
import 'package:agrilend/features/wallet/screens/send_hbar_screen.dart'; // New import
import 'package:agrilend/features/wallet/screens/wallet_settings_screen.dart'; // New import

import 'dart:async'; // Import for StreamSubscription
import 'package:flutter/foundation.dart'; // Import for ChangeNotifier
import 'package:agrilend/features/auth/screens/user_type_selection_screen.dart';
import 'package:agrilend/features/auth/screens/basic_info_screen.dart';
import 'package:agrilend/features/auth/screens/personal_info_screen.dart';
import 'package:agrilend/features/profile/screens/configure_hedera_account_screen.dart'; // New import
import 'package:agrilend/features/profile/screens/create_hedera_account_screen.dart'; // New import
import 'package:agrilend/features/buyer/screens/deposit_hbar_screen.dart'; // New import
import 'package:agrilend/features/buyer/screens/associate_token_screen.dart'; // New import
import 'package:agrilend/features/buyer/screens/redeem_agritokens_screen.dart'; // New import
import 'package:agrilend/features/buyer/screens/browse_products_screen.dart'; // New import

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final goRouterRefreshStream = ref.watch(goRouterNotifier.stream);

  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: GoRouterRefreshStream(goRouterRefreshStream),
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final userType = authState.user?.userType;

      // ignore: avoid_print
      print('Router Redirect: isAuthenticated=$isAuthenticated, userType=$userType, currentUri=${state.uri}, isLoading=${authState.isLoading}');

      // If auth state is still loading, don't redirect yet.
      if (authState.isLoading) {
        return null; // Or redirect to a loading screen if you have one
      }

      // Si non authentifié et pas sur les pages publiques
      if (!isAuthenticated) {
        final publicRoutes = [
          '/onboarding',
          '/login',
          '/register',
          '/user-type-selection',
          '/basic-info',
          '/personal-info',
          '/kyc-verification',
          '/registration-complete'
        ];
        if (!publicRoutes
            .any((route) => state.uri.toString().startsWith(route))) {
          return '/login';
        }
        return null;
      }

      // Si authentifié mais sur les pages publiques
      if (isAuthenticated) {
        final publicRoutes = [
          '/onboarding',
          '/login',
          '/register',
          '/user-type-selection',
          '/basic-info',
          '/personal-info',
          '/kyc-verification',
          '/registration-complete'
        ];
        if (publicRoutes
            .any((route) => state.uri.toString().startsWith(route))) {
          return _getHomeRoute(userType);
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/onboarding',
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      // Onboarding & Auth
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/user-type-selection',
        builder: (context, state) => const UserTypeSelectionScreen(),
      ),
      GoRoute(
        path: '/basic-info',
        builder: (context, state) {
          final userType = state.uri.queryParameters['userType'] ?? 'farmer';
          return BasicInfoScreen(userType: userType);
        },
      ),
      GoRoute(
        path: '/personal-info',
        builder: (context, state) {
          final userType = state.uri.queryParameters['userType'] ?? 'farmer';
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          final password = extra?['password'] as String? ?? '';
          return PersonalInfoScreen(
            userType: userType,
            email: email,
            password: password,
          );
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/kyc-verification',
        builder: (context, state) {
          final userType = state.uri.queryParameters['userType'] ?? 'farmer';
          return KycVerificationScreen(userType: userType);
        },
      ),
      GoRoute(
        path: '/registration-complete',
        builder: (context, state) {
          final userType = state.uri.queryParameters['userType'] ?? 'farmer';
          return RegistrationCompleteScreen(userType: userType);
        },
      ),
      GoRoute(
        path: '/configure-hedera-account',
        builder: (context, state) => const ConfigureHederaAccountScreen(),
      ),
      GoRoute(
        path: '/create-hedera-account',
        builder: (context, state) => const CreateHederaAccountScreen(),
      ),

      // Farmer Routes
      GoRoute(
        path: '/farmer',
        builder: (context, state) => const FarmerMainScreen(),
        routes: [
          GoRoute(
            path: 'payment-request',
            builder: (context, state) => const PaymentRequestScreen(),
          ),
          GoRoute(
            path: 'wallet',
            builder: (context, state) => const WalletScreen(),
            routes: [
              GoRoute(
                path: 'scanner-qr',
                builder: (context, state) => const ScannerQrScreen(),
              ),
              GoRoute(
                path: 'deposit-hbar',
                builder: (context, state) => const DepositHbarScreen(),
              ),
              GoRoute(
                path: 'associate-token',
                builder: (context, state) => const AssociateTokenScreen(),
              ),
              GoRoute(
                path: 'redeem-agritokens',
                builder: (context, state) => const RedeemAgriTokensScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: 'create-offer',
            builder: (context, state) => const CreateOfferScreen(),
          ),
          GoRoute(
            path: 'stock-management',
            builder: (context, state) => const StockManagementScreen(),
          ),
          GoRoute(
            path: 'transaction-history',
            builder: (context, state) => const TransactionHistoryScreen(),
          ),
          GoRoute(
            path: 'edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'support',
            builder: (context, state) => const SupportScreen(),
          ),
        ], // <-- ferme le tableau des routes imbriquées
      ), // <-- ferme le GoRoute /farmer

      // Agent Routes
      GoRoute(
        path: '/agent',
        builder: (context, state) => const AgentMainScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          // GoRoute(
          //   path: 'support',
          //   builder: (context, state) => const SupportScreen(),
          // ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
        ],
      ),

      // Buyer Routes
      GoRoute(
        path: '/buyer',
        builder: (context, state) => const BuyerMainScreen(),
        routes: [
          GoRoute(
            path: 'product/:productId',
            builder: (context, state) {
              final productId = state.pathParameters['productId']!;
              return ProductDetailScreen(productId: productId);
            },
          ),
          GoRoute(
            path: 'offer/:offerId',
            builder: (context, state) {
              final offerId = state.pathParameters['offerId']!;
              return OfferDetailScreen(offerId: offerId);
            },
          ),
          GoRoute(
            path: 'order-confirmation',
            builder: (context, state) => const OrderConfirmationScreen(),
          ),
          GoRoute(
            path: 'orders',
            builder: (context, state) => const OrderListScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: 'edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'support',
            builder: (context, state) => const SupportScreen(),
          ),
          GoRoute(
            path: 'qr-scanner',
            builder: (context, state) => const ScannerQrScreen(),
          ),
          GoRoute(
            path: 'receive-qr',
            builder: (context, state) => const ReceiveQrScreen(),
          ),
          GoRoute(
            path: 'send-hbar',
            builder: (context, state) => const SendHbarScreen(),
          ),
          GoRoute(
            path: 'wallet-settings',
            builder: (context, state) => const WalletSettingsScreen(),
          ),
          GoRoute(
            path: 'orders',
            builder: (context, state) => const OrderListScreen(),
            routes: [
              GoRoute(
                path: 'browse-products',
                builder: (context, state) => const BrowseProductsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'wallet',
            builder: (context, state) => const WalletScreen(),
            routes: [
              GoRoute(
                path: 'deposit-hbar',
                builder: (context, state) => const DepositHbarScreen(),
              ),
              GoRoute(
                path: 'associate-token',
                builder: (context, state) => const AssociateTokenScreen(),
              ),
              GoRoute(
                path: 'redeem-agritokens',
                builder: (context, state) => const RedeemAgriTokensScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

String _getHomeRoute(String? userType) {
  switch (userType) {
    case 'farmer':
      return '/farmer';
    case 'agent':
      return '/agent';
    case 'buyer':
      return '/buyer';
    default:
      return '/login';
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import '../models/user.dart';
import 'package:agrilend/services/farmer_service.dart';
import 'package:agrilend/services/farmer_service.dart'; // New import

import 'package:agrilend/services/buyer_service.dart'; // New import

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  /// Backwards-compatible getter used by feature code
  bool get isAuthenticated => user != null;

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}


 // New import

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService authService;
  final BuyerService buyerService;
  final FarmerService farmerService; // New field

  AuthNotifier(this.authService, this.buyerService, this.farmerService) : super(AuthState()) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    await authService.loadToken(); // Load token first
    User? user = await authService.getCurrentUser(); // Make user mutable

    if (user != null) {
      if (user.userType == 'buyer') {
        final buyerProfile = await buyerService.getBuyerProfile();
        if (buyerProfile != null) {
          user = buyerProfile; // Replace user with fetched profile
        }
      } else if (user.userType == 'farmer') {
        final farmerProfile = await farmerService.getFarmerProfile();
        if (farmerProfile != null) {
          user = farmerProfile; // Replace user with fetched profile
        }
      }
    }
    state = state.copyWith(user: user, isLoading: false);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await authService.login(email, password);
      if (res['success'] == true) {
        final userMap = res['data'] as Map<String, dynamic>;
        // ignore: avoid_print
        print('AuthNotifier login - userMap from API response: $userMap');
        User user = User.fromJson(userMap);

        // If user is a buyer, fetch full profile and update user object
        if (user.userType == 'buyer') {
          final buyerProfile = await buyerService.getBuyerProfile();
          if (buyerProfile != null) {
            user = buyerProfile; // Replace user with fetched profile
          }
        } else if (user.userType == 'farmer') {
          final farmerProfile = await farmerService.getFarmerProfile();
          if (farmerProfile != null) {
            user = farmerProfile; // Replace user with fetched profile
          }
        }
        
        state = state.copyWith(user: user, isLoading: false);
        return true;
      }
      state =
          state.copyWith(isLoading: false, error: res['message']?.toString());
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Accepts either a raw payload map or named parameters (backwards compatible)
  Future<bool> register([Map<String, dynamic>? payload]) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await authService.register(payload ?? {});
      if (res['success'] == true) {
        final user = await authService.getCurrentUser();
        state = state.copyWith(user: user, isLoading: false);
        return true;
      }
      state =
          state.copyWith(isLoading: false, error: res['message']?.toString());
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await authService.logout();
    state = AuthState();
  }

  void updateUserHederaAccountId(String? hederaAccountId) {
    if (state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(hederaAccountId: hederaAccountId),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

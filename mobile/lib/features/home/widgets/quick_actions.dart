import 'package:agrilend/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../farmer/widgets/quick_actions_widget.dart';
import '../../buyer/widgets/buyer_quick_actions_widget.dart'; // Import buyer quick actions
import '../../auth/providers/auth_provider.dart'; // Import authProvider

class QuickActions extends ConsumerWidget {
  // Change to ConsumerWidget
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef
    final userType = ref.watch(authProvider).user?.userType; // Get actual userType

    if (userType == 'farmer') {
      return const QuickActionsWidget();
    } else if (userType == 'buyer') {
      // Assuming 'buyer' is the userType for buyers
      return const BuyerQuickActionsWidget();
    } else {
      return const SizedBox.shrink(); // Or a default empty state
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../farmer/widgets/quick_actions_widget.dart';
import '../../buyer/widgets/buyer_quick_actions_widget.dart'; // Import buyer quick actions

class QuickActions extends ConsumerWidget {
  // Change to ConsumerWidget
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef
    // TEMP : userType démo
    final userType = 'farmer';

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

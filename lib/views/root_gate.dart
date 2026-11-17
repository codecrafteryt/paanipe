import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';
import 'customer/customer_shell.dart';
import 'seller/seller_shell.dart';
import 'widgets/app_loader.dart';

/// Loader while the session resolves, then the customer shell (guests too) or the seller shell.
class RootGate extends GetView<AuthController> {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.state.value == SessionState.loading) return const AppLoader(fullScreen: true);
      return controller.isSeller ? const SellerShell() : const CustomerShell();
    });
  }
}

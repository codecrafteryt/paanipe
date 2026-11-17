import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/cart_controller.dart';
import '../../controller/nav_controller.dart';
import '../common/profile_tab.dart';
import '../widgets/app_shell.dart';
import '../widgets/glass_nav/glass_nav_item.dart';
import 'cart_tab.dart';
import 'customer_orders_tab.dart';
import 'home_tab.dart';

/// Buyer shell: Explore · Cart · Orders · Profile.
class CustomerShell extends GetView<NavController> {
  const CustomerShell({super.key});

  static const explore = 0;
  static const cart = 1;
  static const orders = 2;

  @override
  String get tag => NavController.customer;

  @override
  Widget build(BuildContext context) {
    final cartCtrl = Get.find<CartController>();
    return AppShell(
      nav: controller,
      tabs: () => [
        (
          item: const GlassNavItem(
            label: 'Explore',
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore,
          ),
          page: const HomeTab(),
        ),
        (
          item: GlassNavItem(
            label: 'Cart',
            icon: Icons.shopping_cart_outlined,
            selectedIcon: Icons.shopping_cart,
            badgeCount: cartCtrl.count,
          ),
          page: const CartTab(),
        ),
        (
          item: const GlassNavItem(
            label: 'Orders',
            icon: Icons.receipt_long_outlined,
            selectedIcon: Icons.receipt_long,
          ),
          page: const CustomerOrdersTab(),
        ),
        (
          item: const GlassNavItem(label: 'Profile', icon: Icons.person_outline, selectedIcon: Icons.person),
          page: const ProfileTab(),
        ),
      ],
    );
  }
}

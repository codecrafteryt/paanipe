import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/cart_controller.dart';
import '../../controller/nav_controller.dart';
import '../../utils/values/my_images.dart';
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
          item: const GlassNavItem(label: 'Explore', svg: MyImages.searchSvg),
          page: const HomeTab(),
        ),
        (
          item: GlassNavItem(
            label: 'Cart',
            svg: MyImages.shoppingCartSvg,
            badgeCount: cartCtrl.count,
          ),
          page: const CartTab(),
        ),
        (
          item: const GlassNavItem(label: 'Orders', svg: MyImages.tripsSvg),
          page: const CustomerOrdersTab(),
        ),
        (
          item: const GlassNavItem(label: 'Profile', svg: MyImages.profileSvg),
          page: const ProfileTab(),
        ),
      ],
    );
  }
}

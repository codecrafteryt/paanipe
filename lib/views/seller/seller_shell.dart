import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../controller/nav_controller.dart';
import '../../controller/seller_controller.dart';
import '../../controller/store_form_controller.dart';
import '../../data/models/store.dart';
import '../widgets/app_shell.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_nav/glass_nav_item.dart';
import '../widgets/state_view.dart';
import 'products_tab.dart';
import 'seller_orders_tab.dart';
import 'store_settings_tab.dart';

/// Seller mode: "Create store" until one exists, then orders / products / store tabs.
class SellerShell extends GetView<SellerController> {
  const SellerShell({super.key});

  @override
  Widget build(BuildContext context) {
    return StateView<StoreModel?>(
      state: controller.store,
      builder: (store) => store == null
          ? const _CreateStore()
          : AppShell(
              nav: Get.find(tag: NavController.seller),
              tabs: () => [
                (
                  item: GlassNavItem(
                    label: 'Orders',
                    icon: Icons.receipt_long_outlined,
                    selectedIcon: Icons.receipt_long,
                    badgeCount: controller.newOrders.length,
                  ),
                  page: const SellerOrdersTab(),
                ),
                (
                  item: const GlassNavItem(
                    label: 'Products',
                    icon: Icons.water_drop_outlined,
                    selectedIcon: Icons.water_drop,
                  ),
                  page: const ProductsTab(),
                ),
                (
                  item: GlassNavItem(
                    label: 'My store',
                    icon: Icons.storefront_outlined,
                    selectedIcon: Icons.storefront,
                    avatarUrl: store.imageUrl,
                  ),
                  page: const StoreSettingsTab(),
                ),
              ],
            ),
    );
  }
}

class _CreateStore extends StatelessWidget {
  const _CreateStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller mode'),
        actions: [
          TextButton.icon(
            onPressed: () => Get.find<AuthController>().switchMode(AppMode.customer),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Customer'),
          ),
        ],
      ),
      body: const EmptyState(
        icon: Icons.storefront,
        title: 'Create your store',
        subtitle: 'Add your shop details and delivery charges. Customers near you can order right away.',
        actionLabel: 'Create store',
        onAction: StoreFormController.open,
      ),
    );
  }
}

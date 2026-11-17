import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/store_detail_controller.dart';
import '../../data/models/product.dart';
import '../widgets/app_loader.dart';
import '../widgets/empty_state.dart';
import '../widgets/store_detail/menu_item_tile.dart';
import '../widgets/store_detail/store_cart_bar.dart';
import '../widgets/store_detail/store_hero_bar.dart';
import '../widgets/store_detail/store_intro.dart';

/// Airbnb-style store page: hero photo → info → menu, with a reserve-style cart bar.
class StoreDetailScreen extends GetView<StoreDetailController> {
  const StoreDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final store = controller.store.value;
        if (controller.store.isLoading.value) return const AppLoader();
        if (store == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(icon: Icons.storefront_outlined, title: 'Store not found'),
          );
        }
        return CustomScrollView(
          controller: controller.scroll,
          slivers: [
            StoreHeroBar(
              store: store,
              height: StoreDetailController.heroHeight,
              collapsed: controller.collapsed,
            ),
            SliverToBoxAdapter(
              child: StoreIntro(store: store, deliveryText: controller.deliveryText),
            ),
            SliverToBoxAdapter(
              key: controller.menuKey,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Text('Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ),
            _menu(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      }),
      bottomNavigationBar: const StoreCartBar(),
    );
  }

  Widget _menu() {
    final products = controller.products;
    if (products.isLoading.value) {
      return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(32), child: AppLoader()));
    }
    final list = products.value;
    if (products.error.value != null || list.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyState(
          icon: Icons.water_drop_outlined,
          title: products.error.value == null ? 'No items yet' : 'Could not load the menu',
          subtitle: products.error.value,
        ),
      );
    }
    return SliverList.separated(
      itemCount: list.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 24, endIndent: 24, color: Color(0xFFEBEBEB)),
      itemBuilder: (_, i) => _item(list[i]),
    );
  }

  Widget _item(Product p) => Obx(
    () => MenuItemTile(
      product: p,
      qty: controller.qtyOf(p),
      onAdd: controller.canAdd(p) ? () => controller.add(p) : null,
      onRemove: () => controller.remove(p),
    ),
  );
}

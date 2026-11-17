import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/store_detail_controller.dart';
import '../../data/models/product.dart';
import '../../data/models/store.dart';
import '../widgets/cart_bar.dart';
import '../widgets/product_tile.dart';
import '../widgets/qty_stepper.dart';
import '../widgets/state_view.dart';
import '../widgets/store_header.dart';

class StoreDetailScreen extends GetView<StoreDetailController> {
  const StoreDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text(controller.store.value?.name ?? ''))),
      body: StateView<StoreModel?>(
        state: controller.store,
        isEmpty: (s) => s == null,
        emptyIcon: Icons.storefront_outlined,
        emptyTitle: 'Store not found',
        builder: (store) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StoreHeader(store: store!, distanceText: controller.distanceText),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Products', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            StateView<List<Product>>(
              state: controller.products,
              isEmpty: (p) => p.isEmpty,
              emptyIcon: Icons.water_drop_outlined,
              emptyTitle: 'No products yet',
              builder: (products) => Column(
                children: [
                  for (final p in products)
                    ProductTile(
                      product: p,
                      trailing: Obx(
                        () => QtyStepper(
                          qty: controller.qtyOf(p),
                          onAdd: controller.canAdd(p) ? () => controller.add(p) : null,
                          onRemove: () => controller.cart.decrement(p.id),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CartBar(storeId: controller.storeId),
    );
  }
}

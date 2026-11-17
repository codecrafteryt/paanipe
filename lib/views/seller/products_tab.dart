import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/extensions/extentions.dart';
import '../../controller/product_form_controller.dart';
import '../../controller/seller_controller.dart';
import '../../data/models/product.dart';
import '../widgets/product_tile.dart';
import '../widgets/state_view.dart';

class ProductsTab extends GetView<SellerController> {
  const ProductsTab({super.key});

  void _open([Product? p]) {
    final storeId = controller.store.value?.id;
    if (storeId != null) ProductFormController.open(storeId, p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: StateView<List<Product>>(
        state: controller.products,
        isEmpty: (p) => p.isEmpty,
        emptyIcon: Icons.water_drop_outlined,
        emptyTitle: 'Add your first product',
        emptySubtitle: 'e.g. 19 L bottle refill, 6 L bottle, 1.5 L × 12 pack',
        builder: (products) => ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 16, 16, context.bottomInsetPlus(96)),
          itemCount: products.length,
          itemBuilder: (_, i) => ProductTile(
            product: products[i],
            onTap: () => _open(products[i]),
            trailing: Switch(
              value: products[i].inStock,
              onChanged: (v) => controller.setInStock(products[i], v),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _open,
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
    );
  }
}

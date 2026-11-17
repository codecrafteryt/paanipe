import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../data/models/order.dart';
import '../data/models/product.dart';
import '../data/models/store.dart';
import '../utils/helpers/app_messages.dart';

/// Single-store cart. Works for guests too; login is asked at checkout.
class CartController extends GetxController {
  static const _maxQty = 99;

  final store = Rxn<StoreModel>();
  final items = <String, OrderItem>{}.obs;

  int get count => items.values.fold(0, (s, i) => s + i.qty);
  int get subtotal => items.values.fold(0, (s, i) => s + i.lineTotal);
  bool get isEmpty => items.isEmpty;

  int qtyIn(String storeId, String productId) => store.value?.id == storeId ? items[productId]?.qty ?? 0 : 0;

  Future<void> add(StoreModel s, Product p) async {
    final current = store.value;
    if (current != null && current.id != s.id && items.isNotEmpty) {
      final clear = await confirmDialog(
        'Start a new cart?',
        'Your cart has items from ${current.name}. Clear it and add from ${s.name}?',
        ok: 'Clear cart',
      );
      if (!clear) return;
      this.clear();
    }
    store.value = s;
    final qty = items[p.id]?.qty ?? 0;
    if (qty >= _maxQty) return;
    HapticFeedback.selectionClick();
    items[p.id] = OrderItem(
      productId: p.id,
      name: p.name,
      size: p.size,
      price: p.price,
      qty: qty + 1,
      imageUrl: p.imageUrl,
    );
  }

  void increment(String productId) {
    final item = items[productId];
    if (item == null || item.qty >= _maxQty) return;
    HapticFeedback.selectionClick();
    items[productId] = item.withQty(item.qty + 1);
  }

  void decrement(String productId) {
    final item = items[productId];
    if (item == null) return;
    item.qty <= 1 ? items.remove(productId) : items[productId] = item.withQty(item.qty - 1);
    if (items.isEmpty) store.value = null;
  }

  void clear() {
    items.clear();
    store.value = null;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repos/order_repo/order_repo.dart';
import '../data/sample/sample_catalog.dart';
import '../utils/helpers/app_messages.dart';
import '../views/customer/customer_shell.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';
import 'location_controller.dart';
import 'nav_controller.dart';
import 'order_detail_controller.dart';
import 'store_detail_controller.dart';

/// Backs the Cart tab (cart review + checkout).
class CheckoutController extends GetxController {
  final noteCtrl = TextEditingController();
  final isPlacing = false.obs;

  CartController get cart => Get.find();
  LocationController get location => Get.find();
  AuthController get _auth => Get.find();
  static NavController get _nav => Get.find(tag: NavController.customer);

  /// Back to the shell, on the Cart tab.
  static void open() {
    Get.until((r) => r.isFirst);
    _nav.select(CustomerShell.cart);
  }

  double? get distanceKm {
    final here = location.geoPoint;
    return here == null ? null : cart.store.value?.distanceTo(here);
  }

  int get deliveryFee {
    final here = location.geoPoint;
    return here == null ? 0 : cart.store.value?.deliveryFeeTo(here) ?? 0;
  }

  int get total => cart.subtotal + deliveryFee;

  void exploreStores() => _nav.select(CustomerShell.explore);

  void openStore() {
    final id = cart.store.value?.id;
    if (id != null) StoreDetailController.open(id);
  }

  Future<void> clearCart() async {
    if (await confirmDialog('Clear cart?', 'All items will be removed.', ok: 'Clear')) cart.clear();
  }

  Future<void> placeOrder() async {
    final store = cart.store.value;
    final here = location.location.value;
    if (store == null || cart.isEmpty) return;
    if (here == null) return showError('Set your delivery location first');
    if (SampleCatalog.isSample(store.id)) {
      return showError('${store.name} is a demo store. Ordering opens when real shops join.');
    }
    if (!await _auth.requireLogin()) return;
    final user = _auth.profile.value;
    if (user == null) return;

    isPlacing.value = true;
    try {
      final orderId = await Get.find<OrderRepo>().placeOrder(
        customerId: user.uid,
        customerName: user.name,
        customerPhone: user.phone,
        storeId: store.id,
        storeName: store.name,
        storePhone: store.phone,
        items: cart.items.values.toList(),
        subtotal: cart.subtotal,
        deliveryFee: deliveryFee,
        distanceKm: distanceKm ?? 0,
        deliveryLocation: here.geoPoint,
        deliveryAddress: here.address,
        note: noteCtrl.text.trim(),
      );
      cart.clear();
      noteCtrl.clear();
      _nav.select(CustomerShell.orders);
      OrderDetailController.open(orderId);
      showOk('Order placed! The store has been notified.');
    } catch (e) {
      showError('Could not place order: $e');
    } finally {
      isPlacing.value = false;
    }
  }

  @override
  void onClose() {
    noteCtrl.dispose();
    super.onClose();
  }
}

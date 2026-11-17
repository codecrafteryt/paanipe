import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/product.dart';
import '../data/models/store.dart';
import '../data/repos/store_repo/store_repo.dart';
import '../utils/helpers/formatters.dart';
import '../utils/helpers/stream_state.dart';
import '../views/customer/store_detail_screen.dart';
import 'cart_controller.dart';
import 'checkout_controller.dart';
import 'location_controller.dart';

/// Store page: hero photo, info, menu and the reserve-style cart bar.
class StoreDetailController extends GetxController {
  StoreDetailController(this.storeId);

  static const heroHeight = 300.0;

  final String storeId;
  final store = StreamState<StoreModel?>(null);
  final products = StreamState<List<Product>>(const []);
  final scroll = ScrollController();
  final menuKey = GlobalKey();

  /// True once the hero photo has scrolled under the app bar (shows the title).
  final collapsed = false.obs;

  CartController get cart => Get.find();
  LocationController get _location => Get.find();

  static void open(String storeId) => Get.to(
    () => const StoreDetailScreen(),
    binding: BindingsBuilder.put(() => StoreDetailController(storeId)),
  );

  @override
  void onInit() {
    super.onInit();
    final repo = Get.find<StoreRepo>();
    store.bind(repo.store(storeId));
    products.bind(repo.products(storeId));
    scroll.addListener(() => collapsed.value = scroll.offset > heroHeight - 140);
  }

  /// "Free delivery" / "Rs 40 delivery" to the current delivery location.
  String get deliveryText {
    final here = _location.geoPoint;
    final s = store.value;
    return here == null || s == null ? 'Delivery fee at checkout' : feeText(s.deliveryFeeTo(here));
  }

  /// Cheapest in-stock item, for "From Rs 120".
  int? get fromPrice {
    final prices = products.value.where((p) => p.inStock).map((p) => p.price);
    return prices.isEmpty ? null : prices.reduce((a, b) => a < b ? a : b);
  }

  bool canAdd(Product p) => p.inStock;

  int qtyOf(Product p) => cart.qtyIn(storeId, p.id);

  void add(Product p) {
    final s = store.value;
    if (s != null) cart.add(s, p);
  }

  void remove(Product p) => cart.decrement(p.id);

  bool get hasCartItems => !cart.isEmpty && cart.store.value?.id == storeId;

  void viewCart() => CheckoutController.open();

  /// Scrolls the "Menu" heading to just below the pinned app bar.
  void scrollToMenu() {
    final box = menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !scroll.hasClients) return;
    final bar = Get.mediaQuery.padding.top + kToolbarHeight;
    final target = scroll.offset + box.localToGlobal(Offset.zero).dy - bar;
    scroll.animateTo(
      target.clamp(0.0, scroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void onClose() {
    scroll.dispose();
    store.cancel();
    products.cancel();
    super.onClose();
  }
}

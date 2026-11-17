import 'package:get/get.dart';

import '../data/models/order.dart';
import '../data/models/product.dart';
import '../data/models/store.dart';
import '../data/repos/order_repo/order_repo.dart';
import '../data/repos/store_repo/store_repo.dart';
import '../utils/helpers/app_messages.dart';
import '../utils/helpers/stream_state.dart';
import 'auth_controller.dart';

/// Seller shell: my store, its orders and products. Rebinds on login/logout.
class SellerController extends GetxController {
  SellerController({required this.storeRepo, required this.orderRepo});

  final StoreRepo storeRepo;
  final OrderRepo orderRepo;

  final store = StreamState<StoreModel?>(null);
  final orders = StreamState<List<OrderModel>>(const []);
  final products = StreamState<List<Product>>(const []);

  List<OrderModel> get newOrders => orders.value.where((o) => o.status.isNew).toList();
  List<OrderModel> get activeOrders => orders.value.where((o) => o.status.isActive).toList();
  List<OrderModel> get pastOrders => orders.value.where((o) => o.status.isFinal).toList();

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    void bind(SessionState _) {
      final uid = auth.uid;
      if (!auth.isLoggedIn || uid == null) return _cancel();
      store.bind(storeRepo.store(uid));
      orders.bind(orderRepo.storeOrders(uid));
      products.bind(storeRepo.products(uid));
    }

    bind(auth.state.value);
    ever(auth.state, bind);
  }

  Future<void> setOpen(bool open) => _run(() => storeRepo.setOpen(store.value?.id ?? '', open));

  Future<void> setInStock(Product p, bool inStock) =>
      _run(() => storeRepo.setInStock(store.value?.id ?? '', p.id, inStock));

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      showError('Could not update: $e');
    }
  }

  void _cancel() {
    store.cancel();
    orders.cancel();
    products.cancel();
  }

  @override
  void onClose() {
    _cancel();
    super.onClose();
  }
}

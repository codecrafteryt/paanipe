import 'package:get/get.dart';

import '../data/models/product.dart';
import '../data/models/store.dart';
import '../data/repos/store_repo/store_repo.dart';
import '../utils/helpers/formatters.dart';
import '../utils/helpers/stream_state.dart';
import '../views/customer/store_detail_screen.dart';
import 'cart_controller.dart';
import 'location_controller.dart';

class StoreDetailController extends GetxController {
  StoreDetailController(this.storeId);

  final String storeId;
  final store = StreamState<StoreModel?>(null);
  final products = StreamState<List<Product>>(const []);

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
  }

  /// "1.2 km away · Free delivery", or null without a delivery location.
  String? get distanceText {
    final here = _location.geoPoint;
    final s = store.value;
    if (here == null || s == null) return null;
    return '${km(s.distanceTo(here))} away · ${feeText(s.deliveryFeeTo(here))}';
  }

  bool canAdd(Product p) => (store.value?.isOpen ?? false) && p.inStock;

  int qtyOf(Product p) => cart.qtyIn(storeId, p.id);

  void add(Product p) {
    final s = store.value;
    if (s != null) cart.add(s, p);
  }

  bool get hasCartItems => !cart.isEmpty && cart.store.value?.id == storeId;

  @override
  void onClose() {
    store.cancel();
    products.cancel();
    super.onClose();
  }
}

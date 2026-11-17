import 'package:get/get.dart';

import '../data/models/order.dart';
import '../data/repos/order_repo/order_repo.dart';
import '../utils/helpers/stream_state.dart';
import 'auth_controller.dart';

/// "My orders" — follows login/logout so guests see a login prompt instead.
class CustomerOrdersController extends GetxController {
  CustomerOrdersController({required this.orderRepo});

  final OrderRepo orderRepo;
  final orders = StreamState<List<OrderModel>>(const []);

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    void bind(SessionState _) {
      final uid = auth.uid;
      auth.isLoggedIn && uid != null ? orders.bind(orderRepo.customerOrders(uid)) : orders.cancel();
    }

    bind(auth.state.value);
    ever(auth.state, bind);
  }

  @override
  void onClose() {
    orders.cancel();
    super.onClose();
  }
}

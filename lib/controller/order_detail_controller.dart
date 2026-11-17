import 'package:get/get.dart';

import '../data/models/order.dart';
import '../data/repos/order_repo/order_repo.dart';
import '../utils/helpers/app_messages.dart';
import '../utils/helpers/stream_state.dart';
import '../views/customer/order_tracking_screen.dart';
import '../views/seller/seller_order_detail_screen.dart';
import 'auth_controller.dart';

/// One order, live. Shared by the customer tracking and seller detail screens.
class OrderDetailController extends GetxController {
  OrderDetailController(this.orderId);

  final String orderId;
  final order = StreamState<OrderModel?>(null);
  final isBusy = false.obs;

  static Future<void> open(String orderId, {bool asSeller = false}) async {
    final auth = Get.find<AuthController>();
    await auth.settled;
    if (!auth.isLoggedIn) return;
    final binding = BindingsBuilder.put(() => OrderDetailController(orderId));
    final page = asSeller ? () => const SellerOrderDetailScreen() : () => const OrderTrackingScreen();
    Get.to(page, binding: binding);
  }

  @override
  void onInit() {
    super.onInit();
    order.bind(Get.find<OrderRepo>().order(orderId));
  }

  Future<void> setStatus(OrderStatus status, {String? reason}) async {
    isBusy.value = true;
    try {
      await Get.find<OrderRepo>().updateStatus(orderId, status, reason: reason);
    } catch (e) {
      showError('Could not update the order: $e');
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> cancel() async {
    if (await confirmDialog('Cancel order?', 'The store will be told you cancelled.', ok: 'Cancel order')) {
      await setStatus(OrderStatus.cancelled, reason: 'Cancelled by customer');
    }
  }

  Future<void> reject() async {
    if (await confirmDialog('Reject order?', 'The customer will be notified.', ok: 'Reject')) {
      await setStatus(OrderStatus.rejected, reason: 'The store could not take this order');
    }
  }

  @override
  void onClose() {
    order.cancel();
    super.onClose();
  }
}

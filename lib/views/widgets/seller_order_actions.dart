import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/order_detail_controller.dart';
import '../../data/models/order_status.dart';
import 'app_button.dart';
import 'bottom_action_bar.dart';

/// Next-step buttons for the seller, driven by the order's current status.
class SellerOrderActions extends GetView<OrderDetailController> {
  const SellerOrderActions({super.key});

  /// Primary next step per status (matches firestore.rules seller transitions).
  static const _next = {
    OrderStatus.placed: (OrderStatus.accepted, 'Accept order', Icons.check),
    OrderStatus.accepted: (OrderStatus.outForDelivery, 'Out for delivery', Icons.delivery_dining),
    OrderStatus.preparing: (OrderStatus.outForDelivery, 'Out for delivery', Icons.delivery_dining),
    OrderStatus.outForDelivery: (OrderStatus.delivered, 'Mark delivered', Icons.home_outlined),
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.order.value?.status;
      final busy = controller.isBusy.value;
      final next = _next[status];
      if (status == OrderStatus.delivered) {
        return const BottomActionBar(
          children: [
            Expanded(
              child: Text('Waiting for the customer to confirm delivery', textAlign: TextAlign.center),
            ),
          ],
        );
      }
      if (next == null) return const SizedBox.shrink();
      return BottomActionBar(
        children: [
          if (status == OrderStatus.placed)
            Expanded(
              child: AppButton(
                label: 'Reject',
                variant: ButtonVariant.danger,
                onPressed: busy ? null : controller.reject,
              ),
            ),
          if (status == OrderStatus.accepted)
            Expanded(
              child: AppButton(
                label: 'Preparing',
                variant: ButtonVariant.outlined,
                onPressed: busy ? null : () => controller.setStatus(OrderStatus.preparing),
              ),
            ),
          if (status == OrderStatus.placed || status == OrderStatus.accepted) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: AppButton(
              label: next.$2,
              icon: next.$3,
              isLoading: busy,
              onPressed: () => controller.setStatus(next.$1),
            ),
          ),
        ],
      );
    });
  }
}

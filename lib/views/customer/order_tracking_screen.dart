import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/order_detail_controller.dart';
import '../../data/models/order.dart';
import '../../utils/helpers/device_helper.dart';
import '../widgets/app_button.dart';
import '../widgets/bill_summary.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/order_status_banner.dart';
import '../widgets/order_timeline.dart';
import '../widgets/section_card.dart';
import '../widgets/state_view.dart';

class OrderTrackingScreen extends GetView<OrderDetailController> {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text('Order #${controller.order.value?.shortId ?? ''}'))),
      body: StateView<OrderModel?>(
        state: controller.order,
        isEmpty: (o) => o == null,
        emptyTitle: 'Order not found',
        builder: (order) {
          final o = order!;
          final failed = o.status == OrderStatus.rejected && o.cancelReason.isNotEmpty;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OrderStatusBanner(
                status: o.status,
                message: failed ? o.cancelReason : o.status.customerMessage(o.storeName),
              ),
              SectionCard(
                title: 'Progress',
                child: OrderTimeline(status: o.status),
              ),
              BillSummary(
                title: o.storeName,
                items: o.items,
                subtotal: o.subtotal,
                deliveryFee: o.deliveryFee,
                distanceKm: o.distanceKm,
                totalLabel: 'Total · Cash on delivery',
              ),
              SectionCard(title: 'Delivery address', child: Text(o.deliveryAddress)),
              if (o.note.isNotEmpty) SectionCard(title: 'Your note', child: Text(o.note)),
              AppButton(
                label: 'Call ${o.storeName}',
                icon: Icons.call,
                variant: ButtonVariant.outlined,
                onPressed: () => callPhone(o.storePhone),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Obx(() {
        final status = controller.order.value?.status;
        final busy = controller.isBusy.value;
        if (status == OrderStatus.placed) {
          return BottomActionBar(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cancel order',
                  variant: ButtonVariant.danger,
                  isLoading: busy,
                  onPressed: controller.cancel,
                ),
              ),
            ],
          );
        }
        if (status == OrderStatus.delivered) {
          return BottomActionBar(
            children: [
              Expanded(
                child: AppButton(
                  label: 'I received my order',
                  icon: Icons.check,
                  isLoading: busy,
                  onPressed: () => controller.setStatus(OrderStatus.completed),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }
}

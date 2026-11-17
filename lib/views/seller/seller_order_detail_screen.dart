import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/order_detail_controller.dart';
import '../../data/models/order.dart';
import '../../utils/helpers/device_helper.dart';
import '../../utils/helpers/formatters.dart';
import '../widgets/bill_summary.dart';
import '../widgets/info_row.dart';
import '../widgets/order_timeline.dart';
import '../widgets/section_card.dart';
import '../widgets/seller_order_actions.dart';
import '../widgets/state_view.dart';
import '../widgets/status_chip.dart';

class SellerOrderDetailScreen extends GetView<OrderDetailController> {
  const SellerOrderDetailScreen({super.key});

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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    o.customerName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text('${o.customerPhone}\n${dateTime(o.createdAt)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusChip(o.status),
                      IconButton(onPressed: () => callPhone(o.customerPhone), icon: const Icon(Icons.call)),
                    ],
                  ),
                ),
              ),
              SectionCard(
                title: 'Deliver to · ${km(o.distanceKm)} away',
                onTap: () => openInMaps(o.deliveryLocation.latitude, o.deliveryLocation.longitude),
                child: InfoRow(
                  Icons.directions,
                  '${o.deliveryAddress}\nTap to open in Google Maps',
                  bold: true,
                ),
              ),
              if (o.note.isNotEmpty) SectionCard(title: 'Customer note', child: Text(o.note)),
              BillSummary(
                title: 'Items',
                items: o.items,
                subtotal: o.subtotal,
                deliveryFee: o.deliveryFee,
                totalLabel: 'Collect cash',
              ),
              if (o.status.isFailed && o.cancelReason.isNotEmpty)
                SectionCard(title: 'Reason', child: Text(o.cancelReason)),
              SectionCard(
                title: 'Progress',
                child: OrderTimeline(status: o.status),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const SellerOrderActions(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/order_detail_controller.dart';
import '../../controller/seller_controller.dart';
import '../../data/models/order.dart';
import '../widgets/order_list.dart';

class SellerOrdersTab extends GetView<SellerController> {
  const SellerOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    Widget list(List<OrderModel> Function(List<OrderModel>) filter, String empty) => OrderList(
      state: controller.orders,
      filter: filter,
      emptyTitle: empty,
      titleOf: (o) => o.customerName,
      onTap: (o) => OrderDetailController.open(o.id, asSeller: true),
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(controller.store.value?.name ?? 'Orders')),
          bottom: TabBar(
            tabs: [
              Obx(() => Tab(text: 'New (${controller.newOrders.length})')),
              Obx(() => Tab(text: 'Active (${controller.activeOrders.length})')),
              const Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            list((all) => all.where((o) => o.status.isNew).toList(), 'No new orders'),
            list((all) => all.where((o) => o.status.isActive).toList(), 'No orders in progress'),
            list((all) => all.where((o) => o.status.isFinal).toList(), 'No past orders'),
          ],
        ),
      ),
    );
  }
}

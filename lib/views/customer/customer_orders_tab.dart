import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../controller/customer_orders_controller.dart';
import '../../controller/order_detail_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/order_list.dart';

class CustomerOrdersTab extends GetView<CustomerOrdersController> {
  const CustomerOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: Obx(
        () => auth.isLoggedIn
            ? OrderList(
                state: controller.orders,
                titleOf: (o) => o.storeName,
                onTap: (o) => OrderDetailController.open(o.id),
              )
            : EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Login to see your orders',
                subtitle: 'You can browse stores as a guest.',
                actionLabel: 'Login',
                onAction: auth.requireLogin,
              ),
      ),
    );
  }
}

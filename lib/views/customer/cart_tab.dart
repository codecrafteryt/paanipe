import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/checkout_controller.dart';
import '../../controller/nav_controller.dart';
import '../../utils/helpers/formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/bill_summary.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/info_row.dart';
import '../widgets/qty_stepper.dart';
import '../widgets/section_card.dart';
import 'customer_shell.dart';

/// Cart + checkout in one tab.
class CartTab extends GetView<CheckoutController> {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = controller.cart;
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Obx(() {
        final store = cart.store.value;
        if (store == null || cart.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'Your cart is empty',
            subtitle: 'Add water from a store near you.',
            actionLabel: 'Explore stores',
            onAction: () =>
                Get.find<NavController>(tag: NavController.customer).select(CustomerShell.explore),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16), // the action bar below already clears the glass nav
          children: [
            SectionCard(
              title: store.name,
              child: Column(
                children: [
                  for (final item in cart.items.values)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${item.size.isEmpty ? '' : '${item.size} · '}${rs(item.price)}'),
                      trailing: QtyStepper(
                        qty: item.qty,
                        onAdd: () => cart.increment(item.productId),
                        onRemove: () => cart.decrement(item.productId),
                      ),
                    ),
                ],
              ),
            ),
            SectionCard(
              title: 'Deliver to',
              onTap: controller.location.pick,
              child: InfoRow(
                Icons.location_on,
                controller.location.address.isEmpty ? 'Set delivery location' : controller.location.address,
                bold: true,
              ),
            ),
            SectionCard(
              title: 'Note for the store (optional)',
              child: AppTextField(
                controller: controller.noteCtrl,
                hint: 'e.g. Ring the bell, 2nd floor',
                maxLines: 2,
                maxLength: 200,
              ),
            ),
            const SectionCard(
              title: 'Payment',
              child: InfoRow(Icons.payments_outlined, 'Cash on delivery', bold: true),
            ),
            BillSummary(
              subtotal: cart.subtotal,
              deliveryFee: controller.deliveryFee,
              distanceKm: controller.distanceKm,
              footnote: store.feeRulesText,
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(
        () => cart.isEmpty
            ? const SizedBox.shrink()
            : BottomActionBar(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Place order (COD) · ${rs(controller.total)}',
                      isLoading: controller.isPlacing.value,
                      onPressed: controller.placeOrder,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

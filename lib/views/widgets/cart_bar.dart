import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/cart_controller.dart';
import '../../controller/checkout_controller.dart';
import '../../utils/helpers/formatters.dart';
import 'app_button.dart';
import 'bottom_action_bar.dart';

/// "View cart · 3 items · Rs 450" bar; hidden while the cart is empty.
/// [storeId] limits it to the store whose items are in the cart.
class CartBar extends StatelessWidget {
  const CartBar({super.key, this.storeId});

  final String? storeId;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    return Obx(() {
      final hidden = cart.isEmpty || (storeId != null && cart.store.value?.id != storeId);
      if (hidden) return const SizedBox.shrink();
      return BottomActionBar(
        children: [
          Expanded(
            child: AppButton(
              label: 'View cart · ${cart.count} items · ${rs(cart.subtotal)}',
              icon: Icons.shopping_cart_outlined,
              onPressed: CheckoutController.open,
            ),
          ),
        ],
      );
    });
  }
}

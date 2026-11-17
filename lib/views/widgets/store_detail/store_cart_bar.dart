import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/store_detail_controller.dart';
import '../../../utils/helpers/formatters.dart';
import '../../../utils/values/my_color.dart';
import '../app_button.dart';

/// Airbnb "Reserve" bar. Empty cart: "From Rs 120" + Choose water.
/// With items: "Rs 1,240 · 3 items" + View cart.
class StoreCartBar extends GetView<StoreDetailController> {
  const StoreCartBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEBEBEB))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
          child: Obx(() {
            final inCart = controller.hasCartItems;
            final from = controller.fromPrice;
            final cart = controller.cart;
            return Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inCart ? rs(cart.subtotal) : (from == null ? '—' : 'From ${rs(from)}'),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        inCart ? '${cart.count} ${cart.count == 1 ? 'item' : 'items'} · COD' : controller.deliveryText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: MyColors.textSecondary,
                          decoration: TextDecoration.underline,
                          decorationColor: MyColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 156,
                  child: AppButton(
                    label: inCart ? 'View cart' : 'Choose water',
                    onPressed: inCart ? controller.viewCart : controller.scrollToMenu,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

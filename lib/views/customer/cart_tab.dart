import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/checkout_controller.dart';
import '../../utils/helpers/formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/cart/cart_widgets.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_card.dart';
import '../widgets/store_photo.dart';

/// Cart + checkout in one tab (Airbnb "Confirm and pay" layout).
class CartTab extends GetView<CheckoutController> {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = controller.cart;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final store = cart.store.value;
          if (store == null || cart.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add water from a store near you.',
              actionLabel: 'Explore stores',
              onAction: controller.exploreStores,
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Cart', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                  ),
                  TextButton(onPressed: controller.clearCart, child: const Text('Clear')),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: controller.openStore,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(width: 104, height: 80, child: StorePhoto(url: store.imageUrl)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CartInfoText(title: store.name, subtitle: store.address, caption: store.feeRulesText),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const Divider(height: 40, color: Color(0xFFEBEBEB)),
              CartSection(
                title: 'Your items',
                action: 'Add more',
                onAction: controller.openStore,
                child: Column(
                  children: [
                    for (final item in cart.items.values)
                      CartItemRow(
                        item: item,
                        onAdd: () => cart.increment(item.productId),
                        onRemove: () => cart.decrement(item.productId),
                      ),
                  ],
                ),
              ),
              CartSection(
                title: 'Deliver to',
                action: 'Edit',
                onAction: controller.location.pick,
                child: CartInfoTile(
                  icon: Icons.location_on_outlined,
                  title: controller.location.address.isEmpty ? 'Set delivery location' : controller.location.address,
                  subtitle: controller.distanceKm == null ? null : '${km(controller.distanceKm!)} from the store',
                ),
              ),
              CartSection(
                title: 'Note for the store',
                child: AppTextField(
                  controller: controller.noteCtrl,
                  hint: 'e.g. Ring the bell, 2nd floor',
                  maxLines: 2,
                  maxLength: 200,
                ),
              ),
              const CartSection(
                title: 'Pay with',
                child: CartInfoTile(
                  icon: Icons.payments_outlined,
                  title: 'Cash on delivery',
                  subtitle: 'Pay the rider when your water arrives',
                ),
              ),
              CartSection(
                title: 'Price details',
                child: Column(
                  children: [
                    KeyValueRow('Items (${cart.count})', rs(cart.subtotal)),
                    KeyValueRow(
                      controller.distanceKm == null ? 'Delivery' : 'Delivery (${km(controller.distanceKm!)})',
                      controller.deliveryFee == 0 ? 'Free' : rs(controller.deliveryFee),
                    ),
                    const Divider(height: 24, color: Color(0xFFEBEBEB)),
                    KeyValueRow('Total (PKR)', rs(controller.total), bold: true),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: Obx(() => cart.isEmpty ? const SizedBox.shrink() : _placeBar()),
    );
  }

  Widget _placeBar() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEBEBEB))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: Row(
            children: [
              Expanded(
                child: CartInfoText(title: rs(controller.total), subtitle: 'Total · Cash on delivery'),
              ),
              SizedBox(
                width: 156,
                child: AppButton(
                  label: 'Place order',
                  isLoading: controller.isPlacing.value,
                  onPressed: controller.placeOrder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controller/cart_controller.dart';
import '../../../controller/checkout_controller.dart';
import '../../../controller/explore_search_controller.dart';
import '../../../controller/location_controller.dart';
import '../../../utils/values/my_color.dart';
import '../../../utils/values/my_images.dart';

const _shadow = [
  BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, 3)),
];

/// Search pill (area title + detail line + chevron) and the round cart button.
class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = Get.find<LocationController>();
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: Get.find<ExploreSearchController>().open,
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(23),
                boxShadow: _shadow,
              ),
              child: Row(
                children: [
                  SvgPicture.asset(MyImages.searchSvg, width: 24, height: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      final parts = location.address.split(',');
                      final title = location.address.isEmpty
                          ? 'Current location'
                          : parts.first.trim();
                      final detail = parts.length > 1
                          ? parts.skip(1).join(',').trim()
                          : 'Deliver now · Cash on delivery';
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: MyColors.textSecondary,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: MyColors.brand),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const _CartButton(),
      ],
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton();

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    return GestureDetector(
      onTap: CheckoutController.open,
      child: Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: _shadow,
        ),
        alignment: Alignment.center,
        child: Obx(
          () => Badge(
            isLabelVisible: cart.count > 0,
            label: Text('${cart.count > 99 ? '99+' : cart.count}'),
            backgroundColor: const Color(0xFFEF4444),
            child: SvgPicture.asset(
              MyImages.shoppingCartSvg,
              width: 24,
              height: 24,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/explore_controller.dart';
import '../../../utils/values/my_color.dart';
import '../../../utils/values/my_images.dart';

/// "No shop available nearby", centred on the screen while the list is up and empty.
class ExploreNoShops extends GetView<ExploreController> {
  const ExploreNoShops({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Obx(() {
          final stores = controller.home.stores;
          final empty =
              !stores.isLoading.value && stores.error.value == null && controller.home.nearby.isEmpty;
          return AnimatedOpacity(
            opacity: empty && controller.isListMode ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(MyImages.noShopPng, width: 72, height: 72),
                    const SizedBox(height: 16),
                    const Text(
                      'No shop available nearby',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "We're working on adding shops to your area. Explore other destinations.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: MyColors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

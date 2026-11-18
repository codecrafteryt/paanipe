import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controller/explore_search_controller.dart';
import '../../../utils/values/my_images.dart';
import '../app_button.dart';
import '../app_text_field.dart';

/// Top panel opened from the Explore search bar.
class ExploreSearchSheet extends GetView<ExploreSearchController> {
  const ExploreSearchSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: controller.queryCtrl,
            label: 'Where',
            hint: 'Area, street or landmark',
            emphasized: true,
            onSubmitted: (_) => controller.search(),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: SvgPicture.asset(MyImages.currentLocationSvg, width: 22, height: 22),
            title: const Text('Current location', style: TextStyle(fontSize: 15)),
            onTap: controller.useMyLocation,
          ),
          const SizedBox(height: 16),
          Obx(
            () => AppButton(
              label: 'Search',
              isLoading: controller.isSearching.value,
              onPressed: controller.search,
            ),
          ),
        ],
      ),
    );
  }
}

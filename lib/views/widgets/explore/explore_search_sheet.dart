import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/explore_search_controller.dart';
import '../../../utils/values/my_color.dart';
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
          Row(
            children: [
              IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back_ios_new, size: 20)),
              const Spacer(),
              TextButton(
                onPressed: controller.clear,
                child: const Text('Clear', style: TextStyle(color: MyColors.brand)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: controller.queryCtrl,
            label: 'Where',
            hint: 'Area, street or landmark',
            emphasized: true,
            autofocus: true,
            onSubmitted: (_) => controller.search(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OptionField(
                  label: 'Location',
                  value: 'Use my location',
                  onTap: controller.useMyLocation,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionField(label: 'Map', value: 'Pick on map', onTap: controller.pickOnMap),
              ),
            ],
          ),
          const SizedBox(height: 24),
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

/// Tap-only field in the same outlined-label style as the inputs.
class _OptionField extends StatelessWidget {
  const _OptionField({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: MyColors.subtleBorder),
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          enabledBorder: border,
          border: border,
        ),
        child: Text(value, style: const TextStyle(color: MyColors.textSecondary)),
      ),
    );
  }
}

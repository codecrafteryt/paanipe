import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/extensions/extentions.dart';
import '../../controller/auth_controller.dart';
import '../../controller/seller_controller.dart';
import '../../controller/store_form_controller.dart';
import '../common/profile_tab.dart' show LogoutTile;
import '../widgets/app_button.dart';
import '../widgets/section_card.dart';
import '../widgets/store_header.dart';
import '../widgets/switch_mode_card.dart';

class StoreSettingsTab extends GetView<SellerController> {
  const StoreSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My store')),
      body: Obx(() {
        final store = controller.store.value;
        if (store == null) return const SizedBox.shrink();
        return ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, context.bottomInsetPlus(16)),
          children: [
            StoreHeader(store: store),
            AppButton(
              label: 'Edit store',
              icon: Icons.edit_outlined,
              variant: ButtonVariant.outlined,
              onPressed: () => StoreFormController.open(store),
            ),
            const SizedBox(height: 12),
            SectionCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                title: const Text('Accepting orders'),
                subtitle: Text(store.isOpen ? 'Customers can order now' : 'Store shows as closed'),
                value: store.isOpen,
                onChanged: controller.setOpen,
              ),
            ),
            SwitchModeCard(
              title: 'Switch to Customer',
              subtitle: 'Order water for yourself',
              icon: Icons.shopping_bag_outlined,
              onTap: () => Get.find<AuthController>().switchMode(AppMode.customer),
            ),
            const SectionCard(padding: EdgeInsets.zero, child: LogoutTile()),
          ],
        );
      }),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../controller/location_controller.dart';
import '../../utils/extensions/extentions.dart';
import '../../utils/values/my_color.dart';
import '../demo/glass_nav_demo.dart';
import '../widgets/section_card.dart';
import '../widgets/switch_mode_card.dart';

/// Customer profile — guests see a login card; everyone can switch to seller.
class ProfileTab extends GetView<AuthController> {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final location = Get.find<LocationController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        final user = controller.profile.value;
        return ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, context.bottomInsetPlus(16)),
          children: [
            if (controller.isLoggedIn && user != null)
              SectionCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: MyColors.brandSoft,
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: MyColors.brand,
                      ),
                    ),
                  ),
                  title: Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  subtitle: Text(user.email),
                  trailing: IconButton(onPressed: controller.editName, icon: const Icon(Icons.edit_outlined)),
                ),
              )
            else
              SwitchModeCard(
                title: 'Login',
                subtitle: 'Sign in with email or Google to place orders',
                icon: Icons.person_outline,
                trailing: Icons.login,
                onTap: controller.requireLogin,
              ),
            SwitchModeCard(
              title: 'Switch to Seller',
              subtitle: 'Sell water from your shop or plant on Pannipe',
              icon: Icons.storefront,
              onTap: () => controller.switchMode(AppMode.seller),
            ),
            SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Delivery location'),
                    subtitle: Text(
                      location.address.isEmpty ? 'Not set' : location.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: location.pick,
                  ),
                  if (kDebugMode)
                    const ListTile(
                      leading: Icon(Icons.blur_on),
                      title: Text('Glass nav demo'),
                      onTap: GlassNavDemo.open,
                    ),
                  if (controller.isLoggedIn) const LogoutTile(),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class LogoutTile extends GetView<AuthController> {
  const LogoutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Color(0xFFDC2626)),
      title: const Text('Log out', style: TextStyle(color: Color(0xFFDC2626))),
      onTap: controller.signOut,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/nav_controller.dart';
import '../../utils/extensions/extentions.dart';
import '../widgets/app_shell.dart';
import '../widgets/glass_nav/floating_glass_nav_bar.dart';

/// Debug-only playground for [FloatingGlassNavBar] with placeholder tabs.
class GlassNavDemo extends GetView<NavController> {
  const GlassNavDemo({super.key});

  static const _tag = 'demo';

  @override
  String get tag => _tag;

  static void open() => Get.to(
    () => const GlassNavDemo(),
    binding: BindingsBuilder.put(() => NavController(collapsibleIndex: 0), tag: _tag),
  );

  static const _icons = [Icons.home_outlined, Icons.search, Icons.favorite_border, Icons.person_outline];

  @override
  Widget build(BuildContext context) {
    return AppShell(
      nav: controller,
      tabs: () => [
        for (var i = 0; i < _icons.length; i++)
          (
            item: GlassNavItem(label: 'Tab ${i + 1}', icon: _icons[i], badgeCount: i == 2 ? 3 : 0),
            page: i == 0 ? const _ScrollTab() : _PlainTab(i + 1),
          ),
      ],
    );
  }
}

/// Tab 1: scroll down to collapse the bar, re-tap Tab 1 (or scroll to top) to expand.
class _ScrollTab extends GetView<NavController> {
  const _ScrollTab();

  @override
  String get tag => GlassNavDemo._tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tab 1 · scroll me')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, context.bottomInsetPlus(16)),
        children: [
          Obx(() => Slider(value: controller.reveal.value, onChanged: controller.setReveal)),
          const Text('Reveal factor (slide the bar away)'),
          for (var i = 1; i <= 40; i++)
            Card(
              color: Colors.primaries[i % Colors.primaries.length].shade200,
              child: ListTile(title: Text('Row $i')),
            ),
        ],
      ),
    );
  }
}

class _PlainTab extends StatelessWidget {
  const _PlainTab(this.number);

  final int number;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Tab $number', style: const TextStyle(fontSize: 24))),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/nav_controller.dart';
import 'glass_nav/floating_glass_nav_bar.dart';

typedef ShellTab = ({GlassNavItem item, Widget page});

/// Tabbed shell with the floating glass nav. Content draws behind the bar
/// (`extendBody`); pages get the bar height as `MediaQuery.padding.bottom`.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.nav, required this.tabs, this.busyBackground = false});

  final NavController nav;

  /// Built inside `Obx`, so badges / avatars can read reactive state.
  final List<ShellTab> Function() tabs;
  final bool busyBackground;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = tabs();
      final collapsible = nav.collapsibleIndex;
      return Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: nav.selected.value,
          children: [
            for (var i = 0; i < list.length; i++)
              i == collapsible
                  ? NotificationListener<ScrollNotification>(
                      onNotification: nav.onScroll,
                      child: list[i].page,
                    )
                  : list[i].page,
          ],
        ),
        bottomNavigationBar: FloatingGlassNavBar(
          items: [for (final t in list) t.item],
          selectedIndex: nav.selected.value,
          previousIndex: nav.previous,
          onTabSelected: nav.select,
          collapsed: nav.isCollapsed,
          reveal: nav.effectiveReveal,
          busyBackground: busyBackground,
        ),
      );
    });
  }
}

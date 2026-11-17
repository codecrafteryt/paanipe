import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/explore_controller.dart';
import '../../../controller/nav_controller.dart';
import '../../../utils/values/my_color.dart';
import '../glass_nav/floating_glass_nav_bar.dart';
import 'explore_search_bar.dart';

const _stripHeight = 128.0;

double _sheetTop(BuildContext context, double extent) => MediaQuery.sizeOf(context).height * extent;

/// White search panel (Airbnb): slides up with the sheet and leaves the map full screen.
class ExploreTopChrome extends GetView<ExploreController> {
  const ExploreTopChrome({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Obx(() {
        final reveal = controller.chromeReveal;
        return IgnorePointer(
          ignoring: reveal < 0.05,
          child: FractionalTranslation(
            translation: Offset(0, reveal - 1),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(padding: EdgeInsets.fromLTRB(14, 16, 14, 10), child: ExploreSearchBar()),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Frosted Map ⇄ List pill: above the nav in list mode, above the peek (and card strip) in map mode.
class ExploreTogglePill extends GetView<ExploreController> {
  const ExploreTogglePill({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<NavController>(tag: NavController.customer);
    return Obx(() {
      final list = controller.isListMode;
      final bottom = list
          ? FloatingGlassNavBar.overlayOffset(context, collapsed: nav.isCollapsed) + 12
          : _sheetTop(context, ExploreController.peek) + 12 + (controller.showCards ? _stripHeight : 0);
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        left: 0,
        right: 0,
        bottom: list || controller.isMapMode ? bottom : -80,
        child: Center(
          child: GlassPillButton(
            icon: list ? Icons.map_outlined : Icons.view_list_rounded,
            label: list ? 'Map' : 'List',
            onTap: controller.toggleMapList,
          ),
        ),
      );
    });
  }
}

/// Indigo "Search this area" after the user pans/zooms the map.
class ExploreSearchAreaButton extends GetView<ExploreController> {
  const ExploreSearchAreaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final shown = controller.map.hasMoved.value && controller.mapInteractive;
      return Positioned(
        top: MediaQuery.paddingOf(context).top + 16, // search panel is hidden in map mode
        left: 0,
        right: 0,
        child: AnimatedSlide(
          offset: shown ? Offset.zero : const Offset(0, -6),
          duration: const Duration(milliseconds: 250),
          child: Center(
            child: Material(
              color: MyColors.brand,
              borderRadius: BorderRadius.circular(20),
              elevation: 3,
              child: InkWell(
                onTap: controller.searchThisArea,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Search this area',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Swipeable cards for the selected pin, just above the sheet peek.
class ExploreSelectedStrip extends GetView<ExploreController> {
  const ExploreSelectedStrip({super.key, required this.itemBuilder});

  final Widget Function(int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showCards) return const SizedBox.shrink();
      return Positioned(
        left: 0,
        right: 0,
        height: _stripHeight - 12,
        bottom: _sheetTop(context, ExploreController.peek) + 8,
        child: PageView.builder(
          controller: controller.cards,
          itemCount: controller.home.nearby.length,
          onPageChanged: controller.onCardPage,
          itemBuilder: (_, i) =>
              Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: itemBuilder(i)),
        ),
      );
    });
  }
}

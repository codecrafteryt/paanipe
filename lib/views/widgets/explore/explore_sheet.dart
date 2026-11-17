import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/explore_controller.dart';
import '../../../controller/store_detail_controller.dart';
import '../app_loader.dart';
import '../empty_state.dart';
import '../glass_nav/floating_glass_nav_bar.dart';
import 'store_listing_card.dart';

/// Snapping list sheet: peek 0.08 · mid 0.50 · expanded up to the search panel (initial).
class ExploreSheet extends GetView<ExploreController> {
  const ExploreSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: controller.onSheetChanged,
      child: DraggableScrollableSheet(
        controller: controller.sheet,
        initialChildSize: controller.max,
        minChildSize: ExploreController.peek,
        maxChildSize: controller.max,
        snap: true,
        snapSizes: const [ExploreController.mid],
        builder: (context, scroll) {
          controller.listScroll = scroll;
          return Obx(
            () => DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: controller.listScrolled.value ? 0.16 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: NotificationListener<ScrollNotification>(
                onNotification: controller.onListScroll,
                child: CustomScrollView(
                  controller: scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: _SheetHeader()),
                    _content(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context) {
    final home = controller.home;
    final from = controller.location.geoPoint;
    final stores = home.visibleNearby;
    // Spinner only before the first data — background updates keep the list mounted.
    if (home.stores.isLoading.value && stores.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.all(32), child: AppLoader()),
      );
    }
    final error = home.stores.error.value;
    if (error != null && stores.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyState(icon: Icons.error_outline, title: 'Could not load stores', subtitle: error),
      );
    }
    // No results: ExploreNoShops is drawn centred on the screen, above the sheet.
    if (stores.isEmpty || from == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, FloatingGlassNavBar.overlayOffset(context) + 16),
      sliver: SliverList.builder(
        itemCount: stores.length,
        itemBuilder: (_, i) => StoreListingCard(
          store: stores[i],
          onTap: () => StoreDetailController.open(stores[i].id),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}

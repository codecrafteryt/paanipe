import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../controller/explore_controller.dart';
import '../../controller/store_detail_controller.dart';
import '../../data/models/store.dart';
import '../../service/location_service.dart';
import '../../utils/helpers/formatters.dart';
import '../../utils/values/air_bnb_style.dart';
import '../widgets/explore/allow_location_view.dart';
import '../widgets/explore/explore_no_shops.dart';
import '../widgets/explore/explore_overlays.dart';
import '../widgets/explore/explore_sheet.dart';
import '../widgets/explore/selected_store_card.dart';

/// Explore: map behind everything, snapping list sheet, floating search chrome.
class HomeTab extends GetView<ExploreController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final map = controller.map;
    final location = controller.location;
    // Built once; the IgnorePointer wrapper below rebuilds on sheet drag, not the map.
    final mapView = Obx(
      () => GoogleMap(
        initialCameraPosition: map.initialCamera,
        style: kAirbnbLikeMapStyle,
        markers: controller.markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        onMapCreated: map.onMapCreated,
        onCameraMoveStarted: map.onCameraMoveStarted,
        onCameraMove: map.onCameraMove,
        onCameraIdle: map.onCameraIdle,
        onTap: (_) => controller.clearSelection(),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Obx(() {
        if (location.needsPermission.value) {
          return AllowLocationView(
            onAllow: location.allowLocation,
            onManual: location.pick,
            allowLabel: switch (location.access.value) {
              LocationAccess.deniedForever => 'Open Settings',
              LocationAccess.serviceOff => 'Turn on location',
              _ => 'Yes, allow location',
            },
          );
        }
        return Stack(
          children: [
            Positioned.fill(
              child: Obx(() => IgnorePointer(ignoring: !controller.mapInteractive, child: mapView)),
            ),
            const ExploreSearchAreaButton(),
            ExploreSelectedStrip(itemBuilder: (i) => _card(controller.home.nearby[i])),
            const ExploreSheet(),
            const ExploreNoShops(),
            const ExploreTogglePill(),
            const ExploreTopChrome(),
          ],
        );
      }),
    );
  }

  Widget _card(StoreModel store) {
    final here = controller.location.geoPoint;
    return SelectedStoreCard(
      store: store,
      distance: here == null ? '' : km(store.distanceTo(here)),
      feeLabel: controller.feeLabel(store),
      onTap: () => StoreDetailController.open(store.id),
      onClose: controller.clearSelection,
    );
  }
}

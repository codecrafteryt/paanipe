import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../controller/map_picker_controller.dart';
import '../../utils/values/air_bnb_style.dart';
import '../../utils/values/my_color.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/info_row.dart';

class MapPickerScreen extends GetView<MapPickerController> {
  const MapPickerScreen({super.key, this.showAppBar = true});

  /// False when embedded in an [AppSheetScaffold] (which already has a title + X).
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(controller.title)) : null,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: controller.target, zoom: 16),
            style: kAirbnbLikeMapStyle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: controller.onMapCreated,
            onCameraMoveStarted: controller.onCameraMoveStarted,
            onCameraMove: controller.onCameraMove,
            onCameraIdle: controller.onCameraIdle,
          ),
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 44),
                child: Icon(Icons.location_on, size: 48, color: MyColors.brand),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              onPressed: controller.goToMyLocation,
              child: const Icon(Icons.my_location, color: MyColors.brand),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: InfoRow(
                Icons.place_outlined,
                controller.isResolving.value ? 'Finding address…' : controller.address.value,
                bold: true,
              ),
            ),
            BottomActionBar(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Confirm location',
                    onPressed: controller.canConfirm ? controller.confirm : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

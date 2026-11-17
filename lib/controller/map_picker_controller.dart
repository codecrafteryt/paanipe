import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/constants.dart';
import '../data/models/picked_location.dart';
import '../service/location_service.dart';
import '../utils/helpers/app_messages.dart';
import '../views/common/map_picker_screen.dart';
import '../views/widgets/app_sheet/app_bottom_sheet.dart';
import '../views/widgets/app_sheet/app_sheet_scaffold.dart';

/// Drag-the-map-under-a-pin location picker.
class MapPickerController extends GetxController {
  MapPickerController(this.title, this.initial);

  final String title;
  final PickedLocation? initial;

  late LatLng target = LatLng(initial?.lat ?? Constants.defaultLat, initial?.lng ?? Constants.defaultLng);
  final address = ''.obs;
  final isResolving = true.obs;
  final isMoving = false.obs;
  GoogleMapController? _map;
  Timer? _debounce;

  bool get canConfirm => !isResolving.value && !isMoving.value;

  /// Full-screen route, or a ~90% bottom sheet when [asSheet].
  static Future<PickedLocation?> pick(String title, {PickedLocation? initial, bool asSheet = false}) async {
    if (!asSheet) {
      return Get.to<PickedLocation>(
        () => const MapPickerScreen(),
        binding: BindingsBuilder.put(() => MapPickerController(title, initial)),
      );
    }
    final context = Get.context;
    if (context == null) return null;
    Get.put(MapPickerController(title, initial));
    final result = await showAppModalBottomSheet<PickedLocation>(
      context: context,
      topRadius: 20,
      enableDrag: false, // map gestures must not drag the sheet
      child: AppSheetScaffold(
        title: title,
        scrollable: false,
        bodyPadding: EdgeInsets.zero,
        body: SizedBox(height: Get.height * 0.8, child: const MapPickerScreen(showAppBar: false)),
      ),
    );
    await Get.delete<MapPickerController>();
    return result;
  }

  @override
  void onReady() {
    super.onReady();
    initial == null ? goToMyLocation() : _resolve();
  }

  void onMapCreated(GoogleMapController c) => _map = c;

  void onCameraMoveStarted() => isMoving.value = true;

  void onCameraMove(CameraPosition p) => target = p.target;

  void onCameraIdle() {
    isMoving.value = false;
    _resolve();
  }

  Future<void> goToMyLocation() async {
    final pos = await LocationService.current();
    if (pos == null) {
      showError('Turn on location, or move the map to your place');
      return _resolve();
    }
    target = LatLng(pos.latitude, pos.longitude);
    await _map?.animateCamera(CameraUpdate.newLatLngZoom(target, 17));
    _resolve();
  }

  void _resolve() {
    isResolving.value = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      address.value = await LocationService.addressFor(target.latitude, target.longitude);
      isResolving.value = false;
    });
  }

  void confirm() => Get.back(result: PickedLocation(target.latitude, target.longitude, address.value));

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}

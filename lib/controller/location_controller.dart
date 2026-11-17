import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/constants.dart';
import '../data/models/picked_location.dart';
import '../service/location_service.dart';
import '../utils/helpers/app_messages.dart';
import 'map_picker_controller.dart';

/// Customer delivery location (saved on the device, works for guests) + location permission.
class LocationController extends GetxController {
  LocationController({required this.prefs});

  final SharedPreferences prefs;
  late final location = Rxn<PickedLocation>(_load());

  /// True when we have no location and the user declined the OS prompt (or GPS is off).
  final needsPermission = false.obs;
  final access = LocationAccess.denied.obs;
  late final AppLifecycleListener _lifecycle;

  GeoPoint? get geoPoint => location.value?.geoPoint;
  String get address => location.value?.address ?? '';

  @override
  void onInit() {
    super.onInit();
    ever(location, (p) => needsPermission.value = needsPermission.value && p == null);
    _lifecycle = AppLifecycleListener(onResume: _recheck);
  }

  PickedLocation? _load() {
    final lat = prefs.getDouble(Constants.deliveryLat);
    final lng = prefs.getDouble(Constants.deliveryLng);
    if (lat == null || lng == null) return null;
    return PickedLocation(lat, lng, prefs.getString(Constants.deliveryAddress) ?? '');
  }

  /// No location yet: show the native permission popup straight away (iOS / Android dialog).
  Future<void> ensureLocation() async {
    if (geoPoint != null) return;
    access.value = await LocationService.request();
    if (access.value == LocationAccess.granted && await useCurrentLocation()) return;
    needsPermission.value = true;
  }

  /// Fallback button: re-ask while the OS still allows it, otherwise open Settings.
  Future<void> allowLocation() async {
    if (access.value == LocationAccess.deniedForever || access.value == LocationAccess.serviceOff) {
      await LocationService.openSettings(access.value);
      return;
    }
    access.value = await LocationService.request();
    if (access.value == LocationAccess.granted && !await useCurrentLocation()) {
      showError('Could not get your location. Try again, or set it manually.');
    }
  }

  /// Back from Settings: check only — never re-prompt, or Android would loop
  /// (dismissing the permission dialog itself resumes the app).
  Future<void> _recheck() async {
    if (!needsPermission.value || geoPoint != null) return;
    access.value = await LocationService.status();
    if (access.value == LocationAccess.granted) await useCurrentLocation();
  }

  /// Opens the map picker (full screen, or a sheet). True when a place was chosen.
  Future<bool> pick({bool asSheet = false}) async {
    final picked = await MapPickerController.pick(
      'Delivery location',
      initial: location.value,
      asSheet: asSheet,
    );
    if (picked == null) return false;
    await setLocation(picked);
    return true;
  }

  /// Uses the device GPS position. False when permission / GPS is unavailable.
  Future<bool> useCurrentLocation() async {
    final pos = await LocationService.current();
    if (pos == null) return false;
    final address = await LocationService.addressFor(pos.latitude, pos.longitude);
    await setLocation(PickedLocation(pos.latitude, pos.longitude, address));
    return true;
  }

  Future<void> setLocation(PickedLocation p) async {
    location.value = p;
    await prefs.setDouble(Constants.deliveryLat, p.lat);
    await prefs.setDouble(Constants.deliveryLng, p.lng);
    await prefs.setString(Constants.deliveryAddress, p.address);
  }

  @override
  void onClose() {
    _lifecycle.dispose();
    super.onClose();
  }
}

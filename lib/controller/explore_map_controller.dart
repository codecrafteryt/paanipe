import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/constants.dart';
import '../service/location_service.dart';
import 'home_controller.dart';
import 'location_controller.dart';

/// Explore map camera: ownership (programmatic vs user), zoom bump, recenter, search area.
class ExploreMapController extends GetxController {
  static const _defaultZoom = 15.0;

  final hasMoved = false.obs;

  /// While true, delivery-location changes don't move the camera (after "Search this area").
  bool followLocked = false;

  GoogleMapController? _map;
  late CameraPosition _camera = initialCamera;
  bool _programmatic = false;
  double? _zoomBeforeBump;

  LocationController get _location => Get.find();
  HomeController get _home => Get.find();

  /// Delivery location, else a city fallback.
  CameraPosition get initialCamera {
    final p = _location.geoPoint;
    return CameraPosition(
      target: LatLng(p?.latitude ?? Constants.defaultLat, p?.longitude ?? Constants.defaultLng),
      zoom: _defaultZoom,
    );
  }

  @override
  void onInit() {
    super.onInit();
    ever(_location.location, (p) {
      if (p != null && !followLocked) centerOn(p.geoPoint);
    });
  }

  void onMapCreated(GoogleMapController c) => _map = c;

  /// Only user gestures count as "moved"; our own animations set [_programmatic].
  void onCameraMoveStarted() {
    if (!_programmatic) hasMoved.value = true;
  }

  void onCameraMove(CameraPosition p) => _camera = p;

  void onCameraIdle() => _programmatic = false;

  Future<void> _move(CameraUpdate update) async {
    final map = _map;
    if (map == null) return;
    _programmatic = true;
    await map.animateCamera(update);
    _programmatic = false;
  }

  Future<void> centerOn(GeoPoint? p, {double zoom = _defaultZoom}) async {
    if (p != null) await _move(CameraUpdate.newLatLngZoom(LatLng(p.latitude, p.longitude), zoom));
  }

  void zoomIn() => _move(CameraUpdate.zoomIn());

  void zoomOut() => _move(CameraUpdate.zoomOut());

  /// +1 zoom once when the sheet drops to peek; restore when it rises past mid.
  void onSheetExtent(double extent) {
    final saved = _zoomBeforeBump;
    if (extent <= 0.12 && saved == null) {
      _zoomBeforeBump = _camera.zoom;
      _move(CameraUpdate.zoomTo(_camera.zoom + 1));
    } else if (extent > 0.45 && saved != null) {
      _zoomBeforeBump = null;
      _move(CameraUpdate.zoomTo(saved));
    }
  }

  /// Use the current viewport center and stop following the delivery location.
  void searchThisArea() {
    _home.searchArea(GeoPoint(_camera.target.latitude, _camera.target.longitude));
    hasMoved.value = false;
    followLocked = true;
  }

  /// Back to the device position (or delivery location) and resume following.
  Future<void> recenter() async {
    followLocked = false;
    hasMoved.value = false;
    _home.searchArea(null);
    final pos = await LocationService.current();
    await centerOn(pos == null ? _location.geoPoint : GeoPoint(pos.latitude, pos.longitude));
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../data/constants.dart';
import '../data/models/store.dart';
import '../data/repos/store_repo/store_repo.dart';
import '../utils/helpers/stream_state.dart';
import 'auth_controller.dart';
import 'location_controller.dart';

/// Explore data: nearby stores around the delivery location (or a searched map area).
class HomeController extends GetxController {
  HomeController({required this.storeRepo});

  static const _pageSize = 20;

  final StoreRepo storeRepo;
  final stores = StreamState<List<StoreModel>>(const []);

  /// Set by "Search this area"; null = around the delivery location.
  final searchCenter = Rxn<GeoPoint>();
  final _visible = _pageSize.obs;
  Timer? _pageDebounce;

  LocationController get _location => Get.find();

  @override
  void onInit() {
    super.onInit();
    stores.bind(storeRepo.allStores());
  }

  /// Stores near the search center (my own excluded): open first, then nearest.
  List<StoreModel> get nearby {
    final center = searchCenter.value ?? _location.geoPoint;
    if (center == null) return const [];
    final myId = Get.find<AuthController>().uid;
    return stores.value
        .where((s) => s.id != myId && s.distanceTo(center) <= Constants.nearbyRadiusKm)
        .toList()
      ..sort(
        (a, b) =>
            a.isOpen != b.isOpen ? (a.isOpen ? -1 : 1) : a.distanceTo(center).compareTo(b.distanceTo(center)),
      );
  }

  /// Current page of [nearby] for the list (markers use the full list).
  List<StoreModel> get visibleNearby => nearby.take(_visible.value).toList();

  /// Called near the list bottom; debounced so a fling loads one page.
  void loadMore() {
    if (_pageDebounce?.isActive ?? false) return;
    _pageDebounce = Timer(const Duration(milliseconds: 300), () {
      if (_visible.value < nearby.length) _visible.value += _pageSize;
    });
  }

  void searchArea(GeoPoint? center) {
    searchCenter.value = center;
    _visible.value = _pageSize;
  }

  @override
  void onClose() {
    _pageDebounce?.cancel();
    stores.cancel();
    super.onClose();
  }
}

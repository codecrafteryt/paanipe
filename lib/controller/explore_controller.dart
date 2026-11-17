import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/models/picked_location.dart';
import '../data/models/store.dart';
import '../utils/helpers/formatters.dart';
import '../utils/helpers/price_marker.dart';
import 'explore_map_controller.dart';
import 'home_controller.dart';
import 'location_controller.dart';
import 'nav_controller.dart';

/// Explore screen: the sheet extent drives map interactivity, nav reveal and zoom;
/// map pins are price tags; selection shows a card above the sheet peek.
class ExploreController extends GetxController {
  static const peek = 0.08;
  static const mid = 0.50;

  /// Search panel below the status bar: top padding 16 + bar 46 + bottom padding 10.
  static const chromeHeight = 72.0;

  /// Expanded sheet height: its top tucks 16px under the search panel, so no gap shows.
  final double max = (1 - (Get.mediaQuery.padding.top + chromeHeight - 16) / Get.height)
      .clamp(0.6, 0.95)
      .toDouble();

  final sheet = DraggableScrollableController();
  final cards = PageController(viewportFraction: 0.92);
  late final extent = max.obs;
  final listScrolled = false.obs;
  final selectedId = RxnString();
  final _icons = <String, BitmapDescriptor>{}.obs;

  /// Attached by the sheet builder (used to reset scroll when switching to map mode).
  ScrollController? listScroll;

  HomeController get home => Get.find();
  ExploreMapController get map => Get.find();
  LocationController get location => Get.find();
  NavController get _nav => Get.find(tag: NavController.customer);

  bool get mapInteractive => extent.value <= 0.55;
  bool get isListMode => extent.value >= max - 0.02;
  bool get isMapMode => extent.value <= peek + 0.02;
  bool get showCards => isMapMode && selected != null;
  StoreModel? get selected => home.nearby.firstWhereOrNull((s) => s.id == selectedId.value);

  /// Search panel slide (Airbnb): 1 = shown, 0 = slid up off-screen. Follows the sheet:
  /// fully hidden once the map becomes interactive, fully shown near the top.
  double get chromeReveal => ((extent.value - 0.55) / (max - 0.1 - 0.55)).clamp(0.0, 1.0);

  /// Pin / card price label: delivery fee to the customer.
  String feeLabel(StoreModel s) {
    final here = location.geoPoint;
    final fee = here == null ? 0 : s.deliveryFeeTo(here);
    return fee == 0 ? 'Free' : rs(fee);
  }

  Set<Marker> get markers => {
    for (final s in home.nearby)
      Marker(
        markerId: MarkerId(s.id),
        position: LatLng(s.location.latitude, s.location.longitude),
        icon:
            _icons[PriceMarker.key(feeLabel(s), s.id == selectedId.value)] ?? BitmapDescriptor.defaultMarker,
        anchor: const Offset(0.5, 1),
        zIndexInt: s.id == selectedId.value ? 1 : 0,
        onTap: () => selectStore(s),
      ),
  };

  @override
  void onInit() {
    super.onInit();
    everAll([home.stores.data, location.location, home.searchCenter, selectedId], (_) => _buildIcons());
  }

  @override
  void onReady() {
    super.onReady();
    location.ensureLocation();
  }

  Future<void> _buildIcons() async {
    for (final s in home.nearby) {
      final label = feeLabel(s);
      final selected = s.id == selectedId.value;
      final key = PriceMarker.key(label, selected);
      if (!_icons.containsKey(key)) _icons[key] = await PriceMarker.build(label, selected: selected);
    }
  }

  bool onSheetChanged(DraggableScrollableNotification n) {
    extent.value = n.extent;
    _nav.setReveal(((n.extent - 0.09) / (0.26 - 0.09)).clamp(0.0, 1.0));
    map.onSheetExtent(n.extent);
    return false;
  }

  /// List scroll: shadow, nav collapse (expanded sheet only), pagination. Stops bubbling.
  bool onListScroll(ScrollNotification n) {
    listScrolled.value = n.metrics.pixels > 0;
    if (isListMode) _nav.onScroll(n);
    if (n.metrics.extentAfter < 400) home.loadMore();
    return true;
  }

  Future<void> toggleMapList() async {
    if (isListMode) {
      final scroll = listScroll;
      if (scroll != null && scroll.hasClients) scroll.jumpTo(0);
      return sheet.animateTo(peek, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    }
    _nav.setReveal(1);
    await sheet.animateTo(max, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Future<void> selectStore(StoreModel s, {bool fromCards = false}) async {
    selectedId.value = s.id;
    map.centerOn(s.location, zoom: 16);
    if (!isMapMode) {
      await sheet.animateTo(peek, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    if (fromCards) return;
    final index = home.nearby.indexOf(s);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (cards.hasClients && index >= 0) cards.jumpToPage(index);
    });
  }

  void onCardPage(int i) => selectStore(home.nearby[i], fromCards: true);

  void clearSelection() => selectedId.value = null;

  void searchThisArea() {
    clearSelection();
    map.searchThisArea();
  }

  /// Search sheet result: deliver to [place] and lock the map there.
  Future<void> goTo(PickedLocation place) async {
    await location.setLocation(place);
    clearSelection();
    home.searchArea(null);
    map.followLocked = true;
    await map.centerOn(place.geoPoint);
  }

  /// Search sheet "Use my location": GPS becomes the delivery location and the map follows it.
  Future<void> useMyLocation() async {
    clearSelection();
    if (await location.useCurrentLocation()) await map.recenter();
  }

  @override
  void onClose() {
    sheet.dispose();
    cards.dispose();
    super.onClose();
  }
}

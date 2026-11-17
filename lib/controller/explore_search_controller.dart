import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/picked_location.dart';
import '../service/location_service.dart';
import '../utils/helpers/app_messages.dart';
import '../views/widgets/app_sheet/app_top_sheet.dart';
import '../views/widgets/explore/explore_search_sheet.dart';
import 'explore_controller.dart';

/// Top search panel on Explore: type a place, use GPS, or pick on the map.
class ExploreSearchController extends GetxController {
  final queryCtrl = TextEditingController();
  final isSearching = false.obs;

  ExploreController get _explore => Get.find();

  Future<void> open() async {
    final context = Get.context;
    if (context == null) return;
    queryCtrl.text = _explore.location.address;
    await showAppTopSheet<void>(context: context, child: const ExploreSearchSheet());
  }

  Future<void> search() async {
    final query = queryCtrl.text.trim();
    if (query.isEmpty) return showError('Type an area, street or landmark');
    isSearching.value = true;
    try {
      final match = await LocationService.search(query);
      if (match == null) return showError('No place found for "$query"');
      Get.back<void>();
      await _explore.goTo(PickedLocation(match.latitude, match.longitude, query));
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> useMyLocation() async {
    Get.back<void>();
    await _explore.useMyLocation();
  }

  Future<void> pickOnMap() async {
    Get.back<void>();
    if (await _explore.location.pick(asSheet: true)) {
      final place = _explore.location.location.value;
      if (place != null) await _explore.goTo(place);
    }
  }

  void clear() => queryCtrl.clear();

  @override
  void onClose() {
    queryCtrl.dispose();
    super.onClose();
  }
}

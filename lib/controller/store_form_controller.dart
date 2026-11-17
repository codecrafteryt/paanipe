import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/picked_location.dart';
import '../data/models/store.dart';
import '../data/repos/store_repo/store_repo.dart';
import '../utils/helpers/app_messages.dart';
import '../utils/helpers/delivery_fee.dart';
import '../utils/helpers/device_helper.dart';
import '../utils/helpers/formatters.dart';
import '../views/seller/store_form_screen.dart';
import 'auth_controller.dart';
import 'map_picker_controller.dart';

/// Create / edit store — only the MVP fields.
class StoreFormController extends GetxController {
  StoreFormController(this.existing);

  final StoreModel? existing;
  final formKey = GlobalKey<FormState>();
  late final nameCtrl = TextEditingController(text: existing?.name);
  late final phoneCtrl = TextEditingController(
    text: localPhone(existing?.phone ?? Get.find<AuthController>().profile.value?.phone ?? ''),
  );
  late final descCtrl = TextEditingController(text: existing?.description);
  late final freeKmCtrl = TextEditingController(text: trimNum(existing?.freeWithinKm ?? 3));
  late final perKmCtrl = TextEditingController(text: trimNum(existing?.chargePerKm ?? 20));

  late final location = Rxn<PickedLocation>(
    existing == null ? null : PickedLocation.fromGeoPoint(existing!.location, existing!.address),
  );
  final image = Rxn<File>();
  final isSaving = false.obs;
  final feeExample = ''.obs;

  bool get isNew => existing == null;
  String get imageUrl => existing?.imageUrl ?? '';

  static void open([StoreModel? store]) =>
      Get.to(() => const StoreFormScreen(), binding: BindingsBuilder.put(() => StoreFormController(store)));

  @override
  void onInit() {
    super.onInit();
    updateFeeExample();
  }

  void updateFeeExample() {
    final free = double.tryParse(freeKmCtrl.text) ?? 0;
    final per = double.tryParse(perKmCtrl.text) ?? 0;
    final fee = DeliveryFee.fee(distanceKm: free + 2, freeWithinKm: free, chargePerKm: per);
    feeExample.value =
        'Example: a ${trimNum(free + 2)} km order pays '
        '${fee == 0 ? 'no delivery fee' : '${rs(fee)} delivery'}.';
  }

  Future<void> pickImage() async => image.value = await pickGalleryImage() ?? image.value;

  Future<void> pickLocation() async => location.value =
      await MapPickerController.pick('Store location', initial: location.value) ?? location.value;

  Future<void> save() async {
    final uid = Get.find<AuthController>().uid;
    final loc = location.value;
    if (!(formKey.currentState?.validate() ?? false) || uid == null) return;
    if (loc == null) return showError('Set your store location on the map');
    isSaving.value = true;
    try {
      final repo = Get.find<StoreRepo>();
      final file = image.value;
      await repo.saveStore(
        StoreModel(
          id: uid,
          name: nameCtrl.text.trim(),
          phone: normalizePkPhone(phoneCtrl.text) ?? phoneCtrl.text.trim(),
          description: descCtrl.text.trim(),
          imageUrl: file == null ? imageUrl : await repo.uploadImage(uid, 'profile', file),
          location: loc.geoPoint,
          address: loc.address,
          freeWithinKm: double.parse(freeKmCtrl.text),
          chargePerKm: double.parse(perKmCtrl.text),
          isOpen: existing?.isOpen ?? true,
        ),
        isNew: isNew,
      );
      Get.back();
      showOk(isNew ? 'Store created! Now add your products.' : 'Store updated');
    } catch (e) {
      showError('Could not save store: $e');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    for (final c in [nameCtrl, phoneCtrl, descCtrl, freeKmCtrl, perKmCtrl]) {
      c.dispose();
    }
    super.onClose();
  }
}

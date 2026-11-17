import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/product.dart';
import '../data/repos/store_repo/store_repo.dart';
import '../utils/helpers/app_messages.dart';
import '../utils/helpers/device_helper.dart';
import '../views/seller/product_form_screen.dart';

class ProductFormController extends GetxController {
  ProductFormController(this.storeId, this.existing);

  final String storeId;
  final Product? existing;
  final formKey = GlobalKey<FormState>();
  late final nameCtrl = TextEditingController(text: existing?.name);
  late final sizeCtrl = TextEditingController(text: existing?.size);
  late final priceCtrl = TextEditingController(text: existing?.price.toString());
  late final inStock = (existing?.inStock ?? true).obs;
  final image = Rxn<File>();
  final isSaving = false.obs;

  StoreRepo get _repo => Get.find();
  bool get isNew => existing == null;
  String get imageUrl => existing?.imageUrl ?? '';

  static void open(String storeId, [Product? product]) => Get.to(
    () => const ProductFormScreen(),
    binding: BindingsBuilder.put(() => ProductFormController(storeId, product)),
  );

  Future<void> pickImage() async => image.value = await pickGalleryImage(maxWidth: 800) ?? image.value;

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSaving.value = true;
    try {
      final file = image.value;
      await _repo.saveProduct(
        storeId,
        Product(
          id: existing?.id ?? '',
          name: nameCtrl.text.trim(),
          size: sizeCtrl.text.trim(),
          price: int.parse(priceCtrl.text),
          imageUrl: file == null
              ? imageUrl
              : await _repo.uploadImage(storeId, 'products/${DateTime.now().millisecondsSinceEpoch}', file),
          inStock: inStock.value,
        ),
      );
      Get.back();
      showOk(isNew ? 'Product added' : 'Product updated');
    } catch (e) {
      showError('Could not save product: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete() async {
    final p = existing;
    if (p == null) return;
    if (!await confirmDialog('Delete product?', '${p.name} will be removed.', ok: 'Delete')) return;
    try {
      await _repo.deleteProduct(storeId, p.id);
      Get.back();
    } catch (e) {
      showError('Could not delete: $e');
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    sizeCtrl.dispose();
    priceCtrl.dispose();
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/product_form_controller.dart';
import '../../utils/extensions/extentions.dart';
import '../../utils/helpers/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/photo_picker.dart';

class ProductFormScreen extends GetView<ProductFormController> {
  const ProductFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isNew ? 'Add product' : 'Edit product'),
        actions: [
          if (!controller.isNew)
            IconButton(onPressed: controller.delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Obx(
              () => PhotoPicker(
                url: controller.imageUrl,
                file: controller.image.value,
                label: 'Photo (optional)',
                onTap: controller.pickImage,
              ),
            ),
            24.sbh,
            AppTextField(
              controller: controller.nameCtrl,
              label: 'Product name',
              hint: 'e.g. Mineral water refill',
              capitalization: TextCapitalization.sentences,
              validator: (v) => Validators.required(v, 'Enter a name'),
            ),
            14.sbh,
            AppTextField(controller: controller.sizeCtrl, label: 'Size / pack', hint: 'e.g. 19 L bottle'),
            14.sbh,
            AppTextField(
              controller: controller.priceCtrl,
              label: 'Price',
              prefixText: 'Rs ',
              keyboardType: TextInputType.number,
              inputFormatters: AppTextField.digits(6),
              validator: Validators.positiveInt,
            ),
            8.sbh,
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('In stock'),
                value: controller.inStock.value,
                onChanged: controller.inStock.call,
              ),
            ),
            20.sbh,
            Obx(
              () => AppButton(
                label: controller.isNew ? 'Add product' : 'Save',
                isLoading: controller.isSaving.value,
                onPressed: controller.save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

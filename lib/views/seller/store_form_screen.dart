import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/store_form_controller.dart';
import '../../utils/extensions/extentions.dart';
import '../../utils/helpers/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/info_row.dart';
import '../widgets/photo_picker.dart';
import '../widgets/section_card.dart';

/// Create / edit store — image, name, mobile, description, location, delivery charges.
class StoreFormScreen extends GetView<StoreFormController> {
  const StoreFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      appBar: AppBar(title: Text(c.isNew ? 'Create store' : 'Edit store')),
      body: Form(
        key: c.formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Obx(
              () => PhotoPicker(
                url: c.imageUrl,
                file: c.image.value,
                circle: true,
                label: 'Store photo',
                icon: Icons.storefront,
                onTap: c.pickImage,
              ),
            ),
            24.sbh,
            AppTextField(
              controller: c.nameCtrl,
              label: 'Store name',
              maxLength: 80,
              capitalization: TextCapitalization.words,
              validator: (v) => Validators.minLength(v, 2, 'Enter your store name'),
            ),
            14.sbh,
            AppTextField(
              controller: c.phoneCtrl,
              label: 'Mobile number',
              hint: '03001234567',
              keyboardType: TextInputType.phone,
              inputFormatters: AppTextField.digits(11),
              validator: Validators.phone,
            ),
            14.sbh,
            AppTextField(
              controller: c.descCtrl,
              label: 'Description',
              hint: 'e.g. RO filtered mineral water, 19 L bottles',
              maxLines: 3,
              maxLength: 500,
            ),
            14.sbh,
            Obx(
              () => SectionCard(
                title: 'Store location',
                onTap: c.pickLocation,
                child: InfoRow(
                  Icons.location_on,
                  c.location.value?.address ?? 'Tap to set on map',
                  bold: true,
                ),
              ),
            ),
            const Text('Delivery charges', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            12.sbh,
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: c.freeKmCtrl,
                    label: 'Free delivery within',
                    suffixText: 'km',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => c.updateFeeExample(),
                    validator: (v) => Validators.range(v, 0, 100),
                  ),
                ),
                12.sbw,
                Expanded(
                  child: AppTextField(
                    controller: c.perKmCtrl,
                    label: 'Extra per km',
                    prefixText: 'Rs ',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => c.updateFeeExample(),
                    validator: (v) => Validators.range(v, 0, 1000),
                  ),
                ),
              ],
            ),
            12.sbh,
            Obx(() => InfoRow(Icons.info_outline, c.feeExample.value)),
            28.sbh,
            Obx(
              () => AppButton(
                label: c.isNew ? 'Create store' : 'Save changes',
                isLoading: c.isSaving.value,
                onPressed: c.save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../utils/extensions/extentions.dart';
import '../../utils/values/my_color.dart';
import '../widgets/app_button.dart';
import '../widgets/app_sheet/app_sheet_scaffold.dart';
import '../widgets/app_text_field.dart';

/// First sign-in: name + delivery contact number (stores call this number).
class ProfileSetupSheet extends GetView<AuthController> {
  const ProfileSetupSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: 'Finish signing up',
      expand: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Stores use these to deliver your order.',
            style: TextStyle(color: MyColors.textSecondary, fontSize: 13),
          ),
          20.sbh,
          AppTextField(
            controller: controller.nameCtrl,
            label: 'Full name',
            emphasized: true,
            capitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
          ),
          16.sbh,
          AppTextField(
            controller: controller.phoneCtrl,
            label: 'Mobile number',
            hint: '0300 1234567',
            emphasized: true,
            keyboardType: TextInputType.phone,
            inputFormatters: AppTextField.digits(11),
            autofillHints: const [AutofillHints.telephoneNumber],
            onSubmitted: (_) => controller.saveProfile(),
          ),
        ],
      ),
      footer: Obx(
        () => AppButton(
          label: 'Continue',
          isLoading: controller.isSaving.value,
          onPressed: controller.saveProfile,
        ),
      ),
    );
  }
}

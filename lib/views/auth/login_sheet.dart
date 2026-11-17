import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../utils/extensions/extentions.dart';
import '../../utils/values/my_color.dart';
import '../../utils/values/my_images.dart';
import '../widgets/app_button.dart';
import '../widgets/app_sheet/app_sheet_scaffold.dart';
import '../widgets/app_text_field.dart';
import '../widgets/labeled_divider.dart';

/// "Log in or sign up": email code or Google.
class LoginSheet extends GetView<AuthController> {
  const LoginSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: 'Log in or sign up',
      expand: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: controller.emailCtrl,
            label: 'Email',
            hint: 'you@example.com',
            emphasized: true,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => controller.sendCode(),
          ),
          24.sbh,
          Obx(
            () => AppButton(
              label: 'Continue',
              isLoading: controller.isSending.value,
              onPressed: controller.sendCode,
            ),
          ),
          24.sbh,
          const LabeledDivider('Or'),
          24.sbh,
          Obx(
            () => AppButton(
              label: 'Continue with Google',
              variant: ButtonVariant.social,
              leading: SvgPicture.asset(MyImages.googleSvg),
              isLoading: controller.isGoogleLoading.value,
              onPressed: controller.signInWithGoogle,
            ),
          ),
          16.sbh,
          const Text.rich(
            TextSpan(
              text: 'I have read and accept the ',
              children: [
                TextSpan(
                  text: 'Pannipe Terms Of Use',
                  style: TextStyle(color: MyColors.brand),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Pannipe Privacy Policy',
                  style: TextStyle(color: MyColors.brand),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

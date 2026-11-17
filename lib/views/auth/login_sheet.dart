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

/// Email/password (sign in or register) + Google.
class LoginSheet extends GetView<AuthController> {
  const LoginSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final register = controller.isRegisterMode.value;
      return AppSheetScaffold(
        title: register ? 'Create account' : 'Log in',
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
            ),
            16.sbh,
            AppTextField(
              controller: controller.passwordCtrl,
              label: 'Password',
              hint: register ? 'At least 6 characters' : 'Your password',
              emphasized: true,
              obscureText: controller.obscurePassword.value,
              autofillHints: register
                  ? const [AutofillHints.newPassword]
                  : const [AutofillHints.password],
              onSubmitted: (_) => controller.submitEmailAuth(),
              suffix: IconButton(
                onPressed: controller.toggleObscurePassword,
                icon: Icon(
                  controller.obscurePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                  color: MyColors.textSecondary,
                ),
              ),
            ),
            24.sbh,
            Obx(
              () => AppButton(
                label: register ? 'Create account' : 'Log in',
                isLoading: controller.isAuthLoading.value,
                onPressed: controller.submitEmailAuth,
              ),
            ),
            16.sbh,
            TextButton(
              onPressed: controller.toggleAuthMode,
              child: Text(
                register ? 'Already have an account? Log in' : 'New here? Create an account',
                style: const TextStyle(color: MyColors.brand, fontWeight: FontWeight.w600),
              ),
            ),
            8.sbh,
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
                  TextSpan(text: 'Pannipe Terms Of Use', style: TextStyle(color: MyColors.brand)),
                  TextSpan(text: ' and '),
                  TextSpan(text: 'Pannipe Privacy Policy', style: TextStyle(color: MyColors.brand)),
                ],
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.black87),
            ),
          ],
        ),
      );
    });
  }
}

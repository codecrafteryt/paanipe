import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../data/constants.dart';
import '../../utils/extensions/extentions.dart';
import '../../utils/values/my_color.dart';
import '../widgets/app_button.dart';
import '../widgets/app_sheet/app_sheet_scaffold.dart';
import '../widgets/otp_code_field.dart';

/// "Enter a 6-digit code" — Continue stays disabled until all digits are in.
class OtpSheet extends GetView<AuthController> {
  const OtpSheet({super.key});

  @override
  Widget build(BuildContext context) {
    const grey = TextStyle(color: MyColors.textSecondary, fontSize: 13);
    return AppSheetScaffold(
      title: 'Enter a ${Constants.otpLength}-digit code',
      expand: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your code was emailed to: ${controller.email}', style: grey),
          20.sbh,
          OtpCodeField(
            controller: controller.codeCtrl,
            length: Constants.otpLength,
            onCompleted: (_) => controller.verifyCode(),
          ),
          20.sbh,
          Obx(() {
            final seconds = controller.secondsLeft.value;
            return Row(
              children: [
                const Text("Didn't receive any code?  ", style: grey),
                GestureDetector(
                  onTap: seconds == 0 ? controller.resendCode : null,
                  child: Text(
                    seconds == 0 ? 'Resend code' : 'Resend in ${seconds}s',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: seconds == 0 ? MyColors.brand : MyColors.disabledText,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      footer: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller.codeCtrl,
        builder: (_, value, _) => Obx(
          () => AppButton(
            label: 'Continue',
            isLoading: controller.isVerifying.value,
            onPressed: value.text.length == Constants.otpLength ? controller.verifyCode : null,
          ),
        ),
      ),
    );
  }
}

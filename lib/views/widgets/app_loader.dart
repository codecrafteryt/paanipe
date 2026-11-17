import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/values/my_color.dart';

/// Brand activity spinner. [fullScreen] = white page with the spinner centred.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.fullScreen = false});

  final bool fullScreen;

  static bool _shown = false;

  /// Full-screen blocking loader above everything (e.g. while a sign-in finishes).
  static void show() {
    if (_shown) return;
    _shown = true;
    Get.dialog<void>(
      const PopScope(canPop: false, child: AppLoader(fullScreen: true)),
      barrierDismissible: false,
      barrierColor: Colors.white,
      useSafeArea: false,
    );
  }

  static void hide() {
    if (!_shown) return;
    _shown = false;
    if (Get.isDialogOpen ?? false) Get.back<void>();
  }

  @override
  Widget build(BuildContext context) {
    const spinner = Center(child: CupertinoActivityIndicator(color: MyColors.brand, radius: 16));
    return fullScreen
        ? const ColoredBox(
            color: Colors.white,
            child: SizedBox.expand(child: spinner),
          )
        : spinner;
  }
}

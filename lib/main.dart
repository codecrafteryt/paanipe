import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'data/helper/get_di.dart';
import 'utils/values/app_theme.dart';
import 'views/root_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init();
  runApp(const PannipeApp());
}

class PannipeApp extends StatelessWidget {
  const PannipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => GetMaterialApp(
        title: 'Pannipe',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const RootGate(),
      ),
    );
  }
}

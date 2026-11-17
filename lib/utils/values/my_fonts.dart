import 'package:flutter/foundation.dart';

class MyFonts {
  MyFonts._();

  /// App font: Georgia. iOS/macOS ship it; Android aliases "georgia" to its own
  /// serif, so there we use the bundled Gelasio (OFL, Georgia-metric-compatible).
  static String get georgia =>
      const {TargetPlatform.iOS, TargetPlatform.macOS}.contains(defaultTargetPlatform)
      ? 'Georgia'
      : 'Gelasio';

  static const List<String> fallback = ['Gelasio'];

  @Deprecated('Use MyFonts.georgia')
  static String get roboto => georgia;
}

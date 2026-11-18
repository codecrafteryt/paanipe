import 'package:flutter/material.dart';

/// Design tokens for [FloatingGlassNavBar]. Tweak look & motion here only.
class GlassNavTokens {
  GlassNavTokens._();

  // Surface
  static const double sidePadding = 14;
  static const double radius = 32;
  static const double blur = 18;
  static const double fillOpacity = 0.35;
  static const double busyFillOpacity = 0.60;
  static const double borderOpacity = 0.45;
  static const double busyBorderOpacity = 0.55;
  static const double pillRadius = 24; // floating control pills
  static const double shadowOpacity = 0.10;
  static const double shadowBlur = 24;
  static const Offset shadowOffset = Offset(0, 6);

  // Content
  static const Color iconColor = Color(0xFF333333);
  static const double highlightOpacity = 0.14;
  static const double highlightWidthFactor = 2.0; // × icon size, clamped to the slot
  static const double slotInset = 7;

  // Expanded ↔ collapsed sizes
  static const double iconSize = 22;
  static const double collapsedIconSize = 17;
  static const double contentHeight = 30;
  static const double collapsedContentHeight = 28;
  static const double verticalPadding = 6;
  static const double collapsedVerticalPadding = 5;
  static const double collapsedWidthFactor = 0.78;

  /// Visual pill heights (without the bottom gap) — for positioning overlays.
  static const double expandedHeight = contentHeight + verticalPadding * 2; // 42
  static const double collapsedHeight = collapsedContentHeight + collapsedVerticalPadding * 2; // 38

  // Motion
  static const Duration highlightDuration = Duration(milliseconds: 500);
  static const Curve highlightCurve = Curves.easeOutCubic;
  static const Duration resizeDuration = Duration(milliseconds: 200);
  static const Curve resizeCurve = Curves.easeInOut;
}

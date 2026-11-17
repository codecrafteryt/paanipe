import 'package:flutter/material.dart';

/// App-wide modal sheet presenter: white, rounded top, capped at [maxHeightFactor]
/// of the screen, keyboard-aware via `viewInsets.bottom` only.
Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool bottomSafeArea = true,
  bool showDragHandle = false,
  double topRadius = 15,
  double maxHeightFactor = 0.92,
  bool enableDrag = true, // false for sheets hosting maps or other drag-heavy content
}) {
  final screenHeight = MediaQuery.sizeOf(context).height;
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius))),
    clipBehavior: Clip.antiAlias,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    constraints: BoxConstraints(
      minHeight: 100,
      maxHeight: screenHeight * maxHeightFactor,
      minWidth: double.infinity,
    ),
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      // Keyboard: pad with viewInsets only (never shrink maxHeight from a visibility plugin).
      // Without SafeArea, still clear the home indicator.
      final bottom = media.viewInsets.bottom + (bottomSafeArea ? 0 : media.viewPadding.bottom);
      return Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: bottomSafeArea ? SafeArea(top: false, child: child) : child,
      );
    },
  );
}

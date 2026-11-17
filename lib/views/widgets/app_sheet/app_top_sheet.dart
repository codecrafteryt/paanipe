import 'package:flutter/material.dart';

/// Sheet that drops from the top (search panels). White, rounded bottom corners,
/// bottom grab handle; tap outside or swipe up to close. Completes with the popped value.
Future<T?> showAppTopSheet<T>({required BuildContext context, required Widget child}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black26,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, _, _) => _TopSheet(child: child),
    transitionBuilder: (_, animation, _, page) => SlideTransition(
      position: Tween(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: page,
    ),
  );
}

class _TopSheet extends StatelessWidget {
  const _TopSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onVerticalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) < -200) Navigator.of(context).pop();
        },
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                child,
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 4, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

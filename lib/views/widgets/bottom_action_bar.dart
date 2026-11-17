import 'package:flutter/material.dart';

/// Padded, safe-area bottom bar for primary screen actions.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.children});

  /// Laid out in a Row; wrap buttons in `Expanded`.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(children: children),
      ),
    );
  }
}

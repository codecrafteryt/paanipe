import 'package:flutter/material.dart';

import '../../utils/values/my_color.dart';

/// ───── Or ───── style separator.
class LabeledDivider extends StatelessWidget {
  const LabeledDivider(this.label, {super.key, this.bold = false});

  final String label;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    const line = Expanded(child: Divider(color: MyColors.subtleBorder, height: 1));
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: TextStyle(
              color: bold ? Colors.black : MyColors.disabledText,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

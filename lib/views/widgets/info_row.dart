import 'package:flutter/material.dart';

import '../../utils/values/my_color.dart';

/// Icon + text line (address, delivery rules, distance…).
class InfoRow extends StatelessWidget {
  const InfoRow(this.icon, this.text, {super.key, this.color = MyColors.brand, this.bold = false});

  final IconData icon;
  final String text;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w600 : FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}

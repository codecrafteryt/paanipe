import 'package:flutter/material.dart';

import '../../utils/extensions/extentions.dart';
import '../../utils/values/my_color.dart';

/// Centered icon + title + optional subtitle and action button.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: MyColors.brandSoft,
              child: Icon(icon, size: 40, color: MyColors.brand),
            ),
            16.sbh,
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            if (subtitle != null) ...[
              6.sbh,
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: MyColors.textSecondary),
              ),
            ],
            if (actionLabel != null) ...[
              20.sbh,
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

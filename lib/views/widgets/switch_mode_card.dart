import 'package:flutter/material.dart';

import '../../utils/values/my_color.dart';

/// Brand-coloured call-to-action card ("Switch to Seller", "Login"…).
class SwitchModeCard extends StatelessWidget {
  const SwitchModeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.trailing = Icons.swap_horiz,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final IconData trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: MyColors.brand,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
          trailing: Icon(trailing, color: Colors.white),
        ),
      ),
    );
  }
}

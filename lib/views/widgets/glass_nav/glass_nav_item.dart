import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'glass_nav_tokens.dart';

/// One tab of [FloatingGlassNavBar].
class GlassNavItem {
  const GlassNavItem({
    required this.label,
    required this.icon,
    IconData? selectedIcon,
    this.badgeCount = 0,
    this.avatarUrl,
  }) : selectedIcon = selectedIcon ?? icon;

  /// Used for tooltip / accessibility (the bar is icon-only).
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int badgeCount;

  /// When set (e.g. profile tab), a circular photo replaces the icon.
  final String? avatarUrl;
}

/// Icon / avatar + badge. Badges overlay the glyph, so the layout never shifts.
class GlassNavGlyph extends StatelessWidget {
  const GlassNavGlyph({super.key, required this.item, required this.selected, required this.size});

  final GlassNavItem item;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = item.avatarUrl ?? '';
    Widget glyph = url.isEmpty
        ? Icon(selected ? item.selectedIcon : item.icon, size: size, color: GlassNavTokens.iconColor)
        : Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: selected ? GlassNavTokens.iconColor : Colors.transparent, width: 1.5),
            ),
            child: CircleAvatar(radius: size / 2 - 1.5, backgroundImage: CachedNetworkImageProvider(url)),
          );
    if (item.badgeCount > 0) {
      glyph = Badge(label: Text(item.badgeCount > 99 ? '99+' : '${item.badgeCount}'), child: glyph);
    }
    return Tooltip(
      message: item.label,
      child: Semantics(selected: selected, label: item.label, child: glyph),
    );
  }
}

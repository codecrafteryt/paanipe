import 'dart:ui';

import 'package:flutter/material.dart';

import 'glass_nav_tokens.dart';

typedef _T = GlassNavTokens;

/// Frosted-glass surface shared by the nav bar, search chrome and floating controls.
class GlassSurface extends StatelessWidget {
  const GlassSurface({super.key, required this.child, this.radius = _T.pillRadius, this.busy = false});

  final Widget child;
  final double radius;

  /// Denser fill / border for legibility over maps or photos.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _T.shadowOpacity),
            blurRadius: _T.shadowBlur,
            offset: _T.shadowOffset,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _T.blur, sigmaY: _T.blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: busy ? _T.busyFillOpacity : _T.fillOpacity),
              borderRadius: r,
              border: Border.all(
                color: Colors.white.withValues(alpha: busy ? _T.busyBorderOpacity : _T.borderOpacity),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Frosted pill button (map/list toggle, "Search this area", …).
class GlassPillButton extends StatelessWidget {
  const GlassPillButton({super.key, required this.icon, required this.onTap, this.label});

  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassSurface(
        busy: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: label == null ? 12 : 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: _T.iconColor),
              if (label != null) ...[
                const SizedBox(width: 8),
                Text(
                  label!,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: _T.iconColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

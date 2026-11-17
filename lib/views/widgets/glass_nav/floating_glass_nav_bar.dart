import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../utils/extensions/extentions.dart';
import 'glass_nav_item.dart';
import 'glass_surface.dart';
import 'glass_nav_tokens.dart';

export 'glass_nav_item.dart';
export 'glass_nav_tokens.dart';
export 'glass_surface.dart';

typedef _T = GlassNavTokens;

/// Floating frosted-glass pill navigation. Use as `Scaffold.bottomNavigationBar`
/// with `extendBody: true` so content draws behind it.
class FloatingGlassNavBar extends StatelessWidget {
  const FloatingGlassNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
    this.previousIndex,
    this.collapsed = false,
    this.reveal = 1,
    this.busyBackground = false,
  });

  final List<GlassNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  /// Where the highlight slides from; defaults to [selectedIndex] (no slide).
  final int? previousIndex;
  final bool collapsed;

  /// 0 = hidden (slid down, transparent, no touches) → 1 = fully shown.
  final double reveal;

  /// Denser fill for legibility over maps / photos.
  final bool busyBackground;

  /// Gap under the pill: a reduced version of the system bottom inset.
  static double bottomInset(BuildContext context) {
    final system = BottomInset.systemBottom(context);
    return system <= 0 ? 6 : (system - 18).clamp(6, 40).toDouble();
  }

  /// Bottom offset for FABs / cards that must sit just above the bar.
  static double overlayOffset(BuildContext context, {bool collapsed = false}) =>
      bottomInset(context) + (collapsed ? _T.collapsedHeight : _T.expandedHeight);

  @override
  Widget build(BuildContext context) {
    final inset = bottomInset(context);
    final shown = reveal.clamp(0.0, 1.0);
    return IgnorePointer(
      ignoring: shown < 0.05,
      child: Opacity(
        opacity: shown,
        child: Transform.translate(
          offset: Offset(0, (1 - shown) * (_T.expandedHeight + inset)),
          child: Padding(
            padding: EdgeInsets.fromLTRB(_T.sidePadding, 0, _T.sidePadding, inset),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: collapsed ? 1 : 0),
              duration: _T.resizeDuration,
              curve: _T.resizeCurve,
              builder: (_, t, _) => _pill(t),
            ),
          ),
        ),
      ),
    );
  }

  /// [t]: 0 = expanded, 1 = collapsed.
  Widget _pill(double t) {
    double lerp(double a, double b) => lerpDouble(a, b, t) ?? a;
    final iconSize = lerp(_T.iconSize, _T.collapsedIconSize);
    return LayoutBuilder(
      builder: (_, c) => Align(
        heightFactor: 1,
        child: SizedBox(
          width: c.maxWidth * lerp(1, _T.collapsedWidthFactor),
          child: GlassSurface(
            busy: busyBackground,
            radius: _T.radius,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _T.slotInset,
                vertical: lerp(_T.verticalPadding, _T.collapsedVerticalPadding),
              ),
              child: SizedBox(
                height: lerp(_T.contentHeight, _T.collapsedContentHeight),
                child: _slots(iconSize),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slots(double iconSize) {
    return LayoutBuilder(
      builder: (_, c) {
        final slot = c.maxWidth / items.length;
        final highlight = math.min(iconSize * _T.highlightWidthFactor, slot);
        return Stack(
          children: [
            TweenAnimationBuilder<double>(
              key: ValueKey(selectedIndex),
              tween: Tween(begin: (previousIndex ?? selectedIndex).toDouble(), end: selectedIndex.toDouble()),
              duration: _T.highlightDuration,
              curve: _T.highlightCurve,
              builder: (_, pos, _) => Positioned(
                left: pos * slot + (slot - highlight) / 2,
                top: 0,
                bottom: 0,
                width: highlight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _T.iconColor.withValues(alpha: _T.highlightOpacity),
                    borderRadius: BorderRadius.circular(_T.radius),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTabSelected(i),
                      child: Center(
                        child: GlassNavGlyph(item: items[i], selected: i == selectedIndex, size: iconSize),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

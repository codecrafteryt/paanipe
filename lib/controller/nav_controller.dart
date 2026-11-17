import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Bottom-nav state for one shell: selected tab, highlight origin, collapse, reveal.
/// Registered per shell with a tag ([customer], [seller]).
class NavController extends GetxController {
  NavController({this.collapsibleIndex});

  static const customer = 'customer';
  static const seller = 'seller';

  /// Tab whose vertical scroll collapses the bar (null = never collapses).
  final int? collapsibleIndex;

  final selected = 0.obs;
  final _collapsed = false.obs;

  /// 0 = bar hidden, 1 = shown (drive from sheets / map gestures).
  final reveal = 1.0.obs;
  int previous = 0;

  /// Sheet-driven hiding applies only on the collapsible (Explore) tab.
  double get effectiveReveal => selected.value == collapsibleIndex ? reveal.value : 1;

  /// Collapse applies only while the collapsible tab is showing.
  bool get isCollapsed => _collapsed.value && selected.value == collapsibleIndex;

  void select(int index) {
    if (index == selected.value) {
      if (index == collapsibleIndex) _collapsed.value = false; // re-tap restores full size
      return;
    }
    previous = selected.value;
    selected.value = index;
  }

  void setReveal(double value) => reveal.value = value.clamp(0.0, 1.0);

  /// Hook for the collapsible tab's scroll notifications.
  bool onScroll(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    if (n is UserScrollNotification && n.direction == ScrollDirection.reverse) _collapsed.value = true;
    if (n is ScrollUpdateNotification && n.metrics.pixels <= 0) _collapsed.value = false;
    return false;
  }
}

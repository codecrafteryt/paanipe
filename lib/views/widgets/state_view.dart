import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/helpers/stream_state.dart';
import 'app_loader.dart';
import 'empty_state.dart';

/// Loading / error / empty / content for a [StreamState]. Rebuilds itself reactively.
class StateView<T> extends StatelessWidget {
  const StateView({
    super.key,
    required this.state,
    required this.builder,
    this.isEmpty,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Nothing here yet',
    this.emptySubtitle,
  });

  final StreamState<T> state;
  final Widget Function(T data) builder;
  final bool Function(T data)? isEmpty;
  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptySubtitle;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = state.error.value;
      if (error != null) {
        return EmptyState(icon: Icons.error_outline, title: 'Something went wrong', subtitle: error);
      }
      if (state.isLoading.value) return const AppLoader();
      final data = state.data.value;
      if (isEmpty?.call(data) ?? false) {
        return EmptyState(icon: emptyIcon, title: emptyTitle, subtitle: emptySubtitle);
      }
      return builder(data);
    });
  }
}

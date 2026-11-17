import 'package:flutter/material.dart';

import '../../utils/extensions/extentions.dart';
import '../../data/models/order.dart';
import '../../utils/helpers/stream_state.dart';
import 'order_card.dart';
import 'state_view.dart';

/// Live order list for customers and sellers.
class OrderList extends StatelessWidget {
  const OrderList({
    super.key,
    required this.state,
    required this.titleOf,
    required this.onTap,
    this.filter,
    this.emptyTitle = 'No orders yet',
  });

  final StreamState<List<OrderModel>> state;
  final String Function(OrderModel order) titleOf;
  final void Function(OrderModel order) onTap;

  /// Optional subset (e.g. new / active / past for sellers).
  final List<OrderModel> Function(List<OrderModel> all)? filter;
  final String emptyTitle;

  @override
  Widget build(BuildContext context) {
    List<OrderModel> pick(List<OrderModel> all) => filter?.call(all) ?? all;
    return StateView<List<OrderModel>>(
      state: state,
      isEmpty: (all) => pick(all).isEmpty,
      emptyIcon: Icons.receipt_long_outlined,
      emptyTitle: emptyTitle,
      builder: (all) {
        final orders = pick(all);
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 16, 16, context.bottomInsetPlus(16)),
          itemCount: orders.length,
          itemBuilder: (_, i) =>
              OrderCard(order: orders[i], title: titleOf(orders[i]), onTap: () => onTap(orders[i])),
        );
      },
    );
  }
}

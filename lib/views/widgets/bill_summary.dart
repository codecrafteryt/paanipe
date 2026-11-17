import 'package:flutter/material.dart';

import '../../data/models/order.dart';
import '../../utils/helpers/formatters.dart';
import 'section_card.dart';

/// Items + delivery + total. Used by checkout, order tracking and seller order detail.
class BillSummary extends StatelessWidget {
  const BillSummary({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    this.distanceKm,
    this.items = const [],
    this.title = 'Bill',
    this.totalLabel = 'Total',
    this.footnote,
  });

  final int subtotal;
  final int deliveryFee;
  final double? distanceKm;

  /// Listed line by line when given.
  final List<OrderItem> items;
  final String title;
  final String totalLabel;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final distance = distanceKm;
    return SectionCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final i in items) KeyValueRow(i.label, rs(i.lineTotal)),
          if (items.isNotEmpty) const Divider(),
          KeyValueRow('Items', rs(subtotal)),
          KeyValueRow(
            distance == null ? 'Delivery' : 'Delivery (${km(distance)})',
            deliveryFee == 0 ? 'Free' : rs(deliveryFee),
          ),
          if (footnote != null) Text(footnote!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Divider(),
          KeyValueRow(totalLabel, rs(subtotal + deliveryFee), bold: true),
        ],
      ),
    );
  }
}

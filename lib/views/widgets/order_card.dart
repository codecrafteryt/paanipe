import 'package:flutter/material.dart';

import '../../data/models/order.dart';
import '../../utils/helpers/formatters.dart';
import '../../utils/values/my_color.dart';
import 'section_card.dart';
import 'status_chip.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.title, required this.onTap});

  final OrderModel order;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              StatusChip(order.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(order.itemsSummary, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '#${order.shortId} · ${dateTime(order.createdAt)}',
                style: const TextStyle(color: MyColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              Text(rs(order.total), style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

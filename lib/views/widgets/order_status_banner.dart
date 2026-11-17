import 'package:flutter/material.dart';

import '../../data/models/order_status.dart';

/// Big coloured status header with a one-line explanation.
class OrderStatusBanner extends StatelessWidget {
  const OrderStatusBanner({super.key, required this.status, required this.message});

  final OrderStatus status;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(status.icon, color: status.color, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: TextStyle(color: status.color, fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

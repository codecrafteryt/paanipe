import 'package:flutter/material.dart';

import '../../data/models/order_status.dart';
import '../../utils/values/my_color.dart';

/// Vertical stepper of the happy path; a single red line for cancelled/rejected.
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    if (status.isFailed) {
      return Row(
        children: [
          Icon(status.icon, color: status.color),
          const SizedBox(width: 10),
          Text(
            status.label,
            style: TextStyle(color: status.color, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }
    const steps = OrderStatus.timeline;
    final current = steps.indexOf(status);
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _Step(
            steps[i],
            done: i <= current,
            current: i == current,
            last: i == steps.length - 1,
            lineDone: i < current,
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(
    this.status, {
    required this.done,
    required this.current,
    required this.last,
    required this.lineDone,
  });

  final OrderStatus status;
  final bool done;
  final bool current;
  final bool last;
  final bool lineDone;

  @override
  Widget build(BuildContext context) {
    final grey = Colors.grey.shade300;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: done ? MyColors.brand : grey,
                child: Icon(
                  done ? Icons.check : status.icon,
                  size: 14,
                  color: done ? Colors.white : Colors.grey,
                ),
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: lineDone ? MyColors.brand : grey,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(top: 3, bottom: last ? 0 : 18),
            child: Text(
              status.label,
              style: TextStyle(
                fontWeight: current ? FontWeight.w800 : FontWeight.w500,
                color: done ? null : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

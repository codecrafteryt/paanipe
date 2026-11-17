import 'package:flutter/material.dart';

const _amber = Color(0xFFF59E0B);
const _blue = Color(0xFF3B82F6);
const _red = Color(0xFFDC2626);

/// Order lifecycle. `value` is the Firestore wire value.
enum OrderStatus {
  placed('placed', 'Placed', Icons.receipt_long, _amber),
  accepted('accepted', 'Accepted', Icons.thumb_up_alt_outlined, _blue),
  preparing('preparing', 'Preparing', Icons.inventory_2_outlined, _blue),
  outForDelivery('out_for_delivery', 'Out for delivery', Icons.delivery_dining, Color(0xFF8B5CF6)),
  delivered('delivered', 'Delivered', Icons.home_outlined, Color(0xFF0EA5E9)),
  completed('completed', 'Completed', Icons.check_circle_outline, Color(0xFF16A34A)),
  cancelled('cancelled', 'Cancelled', Icons.cancel_outlined, _red),
  rejected('rejected', 'Rejected', Icons.block, _red);

  const OrderStatus(this.value, this.label, this.icon, this.color);

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  static OrderStatus from(String v) => values.firstWhere((s) => s.value == v, orElse: () => placed);

  /// Happy path shown on the timeline.
  static const timeline = [placed, accepted, preparing, outForDelivery, delivered, completed];

  bool get isFailed => this == cancelled || this == rejected;
  bool get isFinal => isFailed || this == completed;
  bool get isNew => this == placed;
  bool get isActive => !isNew && !isFinal;

  /// Customer-facing one-liner.
  String customerMessage(String storeName) => switch (this) {
    placed => 'Waiting for $storeName to accept your order',
    accepted => '$storeName accepted your order',
    preparing => 'Your water is being prepared',
    outForDelivery => 'Your order is on the way',
    delivered => 'Delivered! Please confirm you received it',
    completed => 'Order completed. Thank you!',
    cancelled => 'You cancelled this order',
    rejected => 'The store could not take this order',
  };
}

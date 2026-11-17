import 'package:flutter/material.dart';

import '../../utils/values/my_color.dart';

/// "Add" button that becomes − qty + once the item is in the cart.
class QtyStepper extends StatelessWidget {
  const QtyStepper({super.key, required this.qty, required this.onAdd, required this.onRemove});

  final int qty;

  /// Null disables adding (closed store / out of stock).
  final VoidCallback? onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (qty == 0) {
      return FilledButton.tonal(
        onPressed: onAdd,
        style: FilledButton.styleFrom(minimumSize: const Size(76, 36)),
        child: const Text('Add'),
      );
    }
    Widget button(IconData icon, VoidCallback? onTap) => IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 18),
    );

    return DecoratedBox(
      decoration: BoxDecoration(color: MyColors.brand, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(Icons.remove, onRemove),
          Text(
            '$qty',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          button(Icons.add, onAdd),
        ],
      ),
    );
  }
}

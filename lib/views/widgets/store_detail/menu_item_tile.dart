import 'package:flutter/material.dart';

import '../../../data/models/product.dart';
import '../../../utils/helpers/formatters.dart';
import '../../../utils/values/my_color.dart';
import '../qty_stepper.dart';
import '../store_photo.dart';

/// Menu row: name, size and price on the left; photo and counter on the right.
class MenuItemTile extends StatelessWidget {
  const MenuItemTile({
    super.key,
    required this.product,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  final Product product;
  final int qty;

  /// Null disables adding (closed store / out of stock).
  final VoidCallback? onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final soldOut = !product.inStock;
    return InkWell(
      onTap: qty == 0 ? onAdd : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  if (product.size.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(product.size, style: const TextStyle(fontSize: 14, color: MyColors.textSecondary)),
                  ],
                  const SizedBox(height: 10),
                  Text(rs(product.price), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  if (soldOut)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('Sold out', style: TextStyle(fontSize: 13, color: MyColors.red)),
                    ),
                  const SizedBox(height: 12),
                  QtyStepper(qty: qty, onAdd: onAdd, onRemove: onRemove),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox.square(
                dimension: 104,
                child: StorePhoto(url: product.imageUrl, dimmed: soldOut, iconSize: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

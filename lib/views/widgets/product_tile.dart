import 'package:flutter/material.dart';

import '../../data/models/product.dart';
import '../../utils/helpers/formatters.dart';
import '../../utils/values/my_color.dart';
import 'net_image.dart';
import 'section_card.dart';

/// Product row. [trailing] is a qty stepper (customer) or stock switch (seller).
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, required this.trailing, this.onTap});

  final Product product;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          NetImage(product.imageUrl, size: 64),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                if (product.size.isNotEmpty)
                  Text(product.size, style: const TextStyle(color: MyColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  rs(product.price),
                  style: const TextStyle(fontWeight: FontWeight.w800, color: MyColors.brand),
                ),
                if (!product.inStock)
                  const Text('Out of stock', style: TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

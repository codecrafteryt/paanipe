import 'package:flutter/material.dart';

import '../../../data/models/order.dart';
import '../../../utils/helpers/formatters.dart';
import '../../../utils/values/my_color.dart';
import '../qty_stepper.dart';
import '../store_photo.dart';

/// Airbnb checkout section: bold title, optional underlined action, content, hairline.
class CartSection extends StatelessWidget {
  const CartSection({super.key, required this.title, required this.child, this.action, this.onAction});

  final String title;
  final Widget child;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEBEBEB)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
              ),
              if (action != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    action!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Cart line: thumbnail, name, size · unit price, counter, line total.
class CartItemRow extends StatelessWidget {
  const CartItemRow({super.key, required this.item, required this.onAdd, required this.onRemove});

  final OrderItem item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox.square(dimension: 64, child: StorePhoto(url: item.imageUrl, iconSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text(
                  '${item.size.isEmpty ? '' : '${item.size} · '}${rs(item.price)}',
                  style: const TextStyle(fontSize: 13, color: MyColors.textSecondary),
                ),
                const SizedBox(height: 8),
                QtyStepper(qty: item.qty, onAdd: onAdd, onRemove: onRemove),
              ],
            ),
          ),
          Text(rs(item.lineTotal), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Icon + title + grey subtitle line (delivery address, payment method).
class CartInfoTile extends StatelessWidget {
  const CartInfoTile({super.key, required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: MyColors.scaffoldMuted, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(fontSize: 13, color: MyColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bold title, grey subtitle and an optional small caption.
class CartInfoText extends StatelessWidget {
  const CartInfoText({super.key, required this.title, required this.subtitle, this.caption});

  final String title;
  final String subtitle;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: MyColors.textSecondary)),
        if (caption != null)
          Text(caption!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: MyColors.textSecondary)),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../data/models/store.dart';
import '../../utils/helpers/device_helper.dart';
import '../../utils/values/my_color.dart';
import 'info_row.dart';
import 'net_image.dart';
import 'section_card.dart';

/// Store photo, name, call button, delivery rules and closed notice.
class StoreHeader extends StatelessWidget {
  const StoreHeader({super.key, required this.store, this.distanceText});

  final StoreModel store;
  final String? distanceText;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NetImage(store.imageUrl, size: 64, radius: 32, icon: Icons.storefront),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text(
                      store.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: MyColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(onPressed: () => callPhone(store.phone), icon: const Icon(Icons.call)),
            ],
          ),
          if (store.description.isNotEmpty) ...[const SizedBox(height: 12), Text(store.description)],
          const Divider(height: 24),
          InfoRow(Icons.delivery_dining, store.feeRulesText),
          if (distanceText != null) InfoRow(Icons.near_me, distanceText!, bold: true),
          if (!store.isOpen)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: InfoRow(
                Icons.lock_clock,
                'This store is closed right now.',
                color: Color(0xFFDC2626),
                bold: true,
              ),
            ),
        ],
      ),
    );
  }
}

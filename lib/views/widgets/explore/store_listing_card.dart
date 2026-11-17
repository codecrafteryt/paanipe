import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/models/store.dart';
import '../../../utils/values/my_color.dart';

/// Large listing card: photo with a badge, name, description, distance and fee.
class StoreListingCard extends StatelessWidget {
  const StoreListingCard({
    super.key,
    required this.store,
    required this.distance,
    required this.feeLabel,
    required this.onTap,
  });

  final StoreModel store;
  final String distance;
  final String feeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final free = feeLabel == 'Free';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: StorePhoto(url: store.imageUrl),
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: _Badge(
                    icon: store.isOpen ? Icons.local_shipping_outlined : Icons.lock_clock,
                    label: store.isOpen ? (free ? 'Free delivery' : 'Open now') : 'Closed',
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  if (store.description.isNotEmpty)
                    Text(
                      store.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: MyColors.textSecondary),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('$distance from current location', style: const TextStyle(fontSize: 12)),
                      ),
                      Text(
                        free ? 'Free' : feeLabel,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      const Text(' delivery', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Store photo filling its box, with a branded placeholder.
class StorePhoto extends StatelessWidget {
  const StorePhoto({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(
      color: MyColors.brandSoft,
      child: Center(child: Icon(Icons.water_drop, color: MyColors.brand, size: 40)),
    );
    if (url.isEmpty) return placeholder;
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: MyColors.brand),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../data/models/store.dart';
import '../../../utils/values/my_color.dart';
import '../store_photo.dart';

/// Compact card for the selected map pin: photo left, details right, close (X) on the photo.
class SelectedStoreCard extends StatelessWidget {
  const SelectedStoreCard({
    super.key,
    required this.store,
    required this.distance,
    required this.feeLabel,
    required this.onTap,
    required this.onClose,
  });

  final StoreModel store;
  final String distance;
  final String feeLabel;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 14, offset: Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  StorePhoto(url: store.imageUrl),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: GestureDetector(
                      onTap: onClose,
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.close, size: 14, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      store.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$distance from you',
                            style: const TextStyle(fontSize: 12, color: MyColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        feeLabel == 'Free' ? 'Free delivery' : '$feeLabel delivery',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

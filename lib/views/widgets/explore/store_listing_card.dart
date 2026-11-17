import 'package:flutter/material.dart';

import '../../../data/models/store.dart';
import '../pin_location.dart';
import '../store_photo.dart';

/// Elevated listing card: photo, store name, then pin + "City, Country".
class StoreListingCard extends StatelessWidget {
  const StoreListingCard({super.key, required this.store, required this.onTap});

  final StoreModel store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'store-${store.id}',
                child: AspectRatio(aspectRatio: 4 / 3, child: StorePhoto(url: store.imageUrl)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    PinLocation(store.cityCountry),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

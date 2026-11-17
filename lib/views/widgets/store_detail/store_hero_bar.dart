import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/store.dart';
import '../../../utils/helpers/device_helper.dart';
import '../store_photo.dart';

/// Airbnb hero: full-bleed photo with round white buttons; collapses into a
/// white bar showing the store name.
class StoreHeroBar extends StatelessWidget {
  const StoreHeroBar({super.key, required this.store, required this.height, required this.collapsed});

  final StoreModel store;
  final double height;
  final RxBool collapsed;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SliverAppBar(
        pinned: true,
        stretch: true,
        expandedHeight: height,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black26,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: Center(child: RoundIconButton(icon: Icons.arrow_back_ios_new, onTap: Get.back)),
        title: AnimatedOpacity(
          opacity: collapsed.value ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: Text(store.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ),
        actions: [
          RoundIconButton(icon: Icons.call_outlined, onTap: () => callPhone(store.phone)),
          const SizedBox(width: 12),
        ],
        flexibleSpace: FlexibleSpaceBar(
          stretchModes: const [StretchMode.zoomBackground],
          background: Hero(
            tag: 'store-${store.id}',
            child: StorePhoto(url: store.imageUrl, iconSize: 64),
          ),
        ),
      ),
    );
  }
}

/// 36px white circle with a soft shadow (back, call, share…).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black38,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox.square(dimension: 36, child: Icon(icon, size: 17, color: Colors.black)),
      ),
    );
  }
}

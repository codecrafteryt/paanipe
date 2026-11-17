import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../data/models/store.dart';
import '../../../utils/values/my_color.dart';
import '../../../utils/values/my_images.dart';
import '../pin_location.dart';

/// Store title, pin + "City, Country", and what the store offers.
class StoreIntro extends StatelessWidget {
  const StoreIntro({super.key, required this.store, required this.deliveryText});

  final StoreModel store;
  final String deliveryText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(store.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 6),
          PinLocation(store.cityCountry, fontSize: 15),
          const _Rule(),
          FeatureRow(MyImages.giftFlatSvg, deliveryText, store.feeRulesText),
          const FeatureRow(MyImages.instantBookSvg, 'Fast delivery', 'Usually at your door in 30–60 min'),
          const FeatureRow(MyImages.moneyFlatSvg, 'Cash on delivery', 'Pay when your water arrives'),
          const _Rule(),
        ],
      ),
    );
  }
}

/// SVG icon, bold title, grey subtitle.
class FeatureRow extends StatelessWidget {
  const FeatureRow(this.svg, this.title, this.subtitle, {super.key});

  final String svg;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox.square(dimension: 28, child: Center(child: SvgPicture.asset(svg, height: 26))),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: MyColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 48, thickness: 1, color: Color(0xFFEBEBEB));
}

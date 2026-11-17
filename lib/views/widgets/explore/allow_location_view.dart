import 'package:flutter/material.dart';

import '../../../utils/values/my_color.dart';
import '../app_button.dart';

/// Full-screen CTA shown instead of the map when we have no coords and no permission.
class AllowLocationView extends StatelessWidget {
  const AllowLocationView({
    super.key,
    required this.onAllow,
    required this.onManual,
    this.allowLabel = 'Yes, allow location',
  });

  final VoidCallback onAllow;
  final VoidCallback onManual;

  /// "Yes, allow location" / "Open Settings" / "Turn on location", per permission state.
  final String allowLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [MyColors.brandSoft, Colors.white],
        ),
      ),
      padding: const EdgeInsets.all(28),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 56,
              backgroundColor: MyColors.brand,
              child: Icon(Icons.location_on, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 28),
            const Text(
              'Find water stores near you',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'Allow location so we can show nearby stores and work out delivery charges.',
              textAlign: TextAlign.center,
              style: TextStyle(color: MyColors.textSecondary),
            ),
            const SizedBox(height: 32),
            AppButton(label: allowLabel, icon: Icons.my_location, onPressed: onAllow),
            TextButton(onPressed: onManual, child: const Text('Set location manually')),
          ],
        ),
      ),
    );
  }
}

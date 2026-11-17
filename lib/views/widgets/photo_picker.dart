import 'dart:io';

import 'package:flutter/material.dart';

import '../../utils/values/my_color.dart';
import 'net_image.dart';

/// Tappable image with a camera badge. [circle] for store avatars, square for products.
class PhotoPicker extends StatelessWidget {
  const PhotoPicker({
    super.key,
    required this.url,
    required this.file,
    required this.onTap,
    this.circle = false,
    this.label = 'Photo',
    this.icon = Icons.add_a_photo_outlined,
  });

  final String url;
  final File? file;
  final VoidCallback onTap;
  final bool circle;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const size = 110.0;
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              children: [
                NetImage(url, file: file, size: size, radius: circle ? size / 2 : 16, icon: icon),
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: MyColors.brand,
                    child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: MyColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../utils/values/my_color.dart';

/// Rounded image from a local [file], a network [url], or a branded placeholder.
class NetImage extends StatelessWidget {
  const NetImage(
    this.url, {
    super.key,
    this.file,
    this.size = 56,
    this.radius = 12,
    this.icon = Icons.water_drop,
  });

  final String url;
  final File? file;
  final double size;
  final double radius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: MyColors.brandSoft,
      child: Icon(icon, color: MyColors.brand, size: size * 0.45),
    );
    final localFile = file;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: localFile != null
          ? Image.file(localFile, width: size, height: size, fit: BoxFit.cover)
          : url.isEmpty
          ? placeholder
          : CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, _) => placeholder,
              errorWidget: (_, _, _) => placeholder,
            ),
    );
  }
}

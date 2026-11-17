import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../utils/values/my_color.dart';

/// Photo filling its box, with a branded placeholder. [dimmed] greys it out (closed store).
class StorePhoto extends StatelessWidget {
  const StorePhoto({super.key, required this.url, this.dimmed = false, this.iconSize = 40});

  final String url;
  final bool dimmed;
  final double iconSize;

  static const _greyscale = ColorFilter.matrix([
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: MyColors.brandSoft,
      child: Center(child: Icon(Icons.water_drop, color: MyColors.brand, size: iconSize)),
    );
    final image = url.isEmpty
        ? placeholder
        : CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 200),
            placeholder: (_, _) => placeholder,
            errorWidget: (_, _, _) => placeholder,
          );
    return dimmed ? ColorFiltered(colorFilter: _greyscale, child: image) : image;
  }
}

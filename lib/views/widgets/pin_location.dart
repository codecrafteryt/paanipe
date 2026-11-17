import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/values/my_color.dart';
import '../../utils/values/my_images.dart';

/// pin.svg + "City, Country" — used by the listing card and the store page.
class PinLocation extends StatelessWidget {
  const PinLocation(this.text, {super.key, this.fontSize = 14});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          MyImages.pinSvg,
          width: fontSize + 2,
          height: fontSize + 2,
          colorFilter: const ColorFilter.mode(MyColors.textSecondary, BlendMode.srcIn),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: fontSize, color: MyColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

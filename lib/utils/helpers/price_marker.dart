import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../values/my_color.dart';
import '../values/my_fonts.dart';

/// Price-tag map pins ("Free", "Rs 40"): white with brand text, or brand-filled when selected.
class PriceMarker {
  PriceMarker._();

  static final _cache = <String, BitmapDescriptor>{};

  static String key(String label, bool selected) => '$label|$selected';

  static BitmapDescriptor? cached(String label, bool selected) => _cache[key(label, selected)];

  static Future<BitmapDescriptor> build(String label, {required bool selected}) async {
    final hit = cached(label, selected);
    if (hit != null) return hit;

    final dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    final text = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontFamily: MyFonts.georgia,
          fontSize: 13 * dpr,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : MyColors.brand,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final pad = Offset(10 * dpr, 6 * dpr);
    final tail = 6 * dpr;
    final shadow = 3 * dpr;
    final body = Rect.fromLTWH(shadow, shadow, text.width + pad.dx * 2, text.height + pad.dy * 2);
    final pill = RRect.fromRectAndRadius(body, Radius.circular(body.height / 2));
    final arrow = Path()
      ..moveTo(body.center.dx - tail, body.bottom - 1)
      ..lineTo(body.center.dx, body.bottom + tail)
      ..lineTo(body.center.dx + tail, body.bottom - 1)
      ..close();
    final shape = Path()
      ..addRRect(pill)
      ..addPath(arrow, Offset.zero);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..drawShadow(shape, Colors.black, shadow, false)
      ..drawPath(shape, Paint()..color = selected ? MyColors.brand : Colors.white)
      ..drawPath(
        shape,
        Paint()
          ..color = MyColors.brand
          ..style = PaintingStyle.stroke
          ..strokeWidth = dpr,
      );
    text.paint(canvas, body.topLeft + pad);

    final image = await recorder.endRecording().toImage(
      (body.width + shadow * 2).ceil(),
      (body.bottom + tail + shadow).ceil(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return BitmapDescriptor.defaultMarker;
    final icon = BitmapDescriptor.bytes(bytes.buffer.asUint8List(), imagePixelRatio: dpr);
    return _cache[key(label, selected)] = icon;
  }
}

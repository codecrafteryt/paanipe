import 'dart:math' as math;

/// Distance + delivery fee rule. Mirrored in `functions/src/index.ts`.
class DeliveryFee {
  DeliveryFee._();

  /// Straight-line (haversine) distance in km.
  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    double rad(double d) => d * math.pi / 180;
    final h =
        math.pow(math.sin(rad(lat2 - lat1) / 2), 2) +
        math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(rad(lng2 - lng1) / 2), 2);
    return 2 * 6371 * math.asin(math.sqrt(h));
  }

  /// 0 inside the free range, else (distance − free range) × Rs/km, rounded up.
  static int fee({required double distanceKm, required double freeWithinKm, required double chargePerKm}) {
    if (distanceKm <= freeWithinKm) return 0;
    return ((distanceKm - freeWithinKm) * chargePerKm).ceil();
  }
}

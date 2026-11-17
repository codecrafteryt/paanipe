class Constants {
  Constants._();

  // ── Firestore collections ──────────────────────────────────────────────
  static const String users = 'users';
  static const String stores = 'stores';
  static const String products = 'products';
  static const String orders = 'orders';

  // ── SharedPreferences keys ─────────────────────────────────────────────
  static const String appMode = 'appMode';
  static const String deliveryLat = 'deliveryLat';
  static const String deliveryLng = 'deliveryLng';
  static const String deliveryAddress = 'deliveryAddress';

  // ── Auth ───────────────────────────────────────────────────────────────
  static const String functionsRegion = 'asia-south1';
  static const int otpLength = 6;
  static const int otpResendSeconds = 60;

  // ── Business rules ─────────────────────────────────────────────────────
  static const double nearbyRadiusKm = 25;
  static const String ordersChannelId = 'pannipe_orders';

  /// Lahore — map fallback when no location is known.
  static const double defaultLat = 31.5204;
  static const double defaultLng = 74.3587;
}

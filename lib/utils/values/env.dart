import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String _req(String key) {
    final v = dotenv.env[key]?.trim() ?? '';
    if (v.isEmpty) {
      throw StateError(
        'Missing `$key` in `.env`. Copy `.env.example` → `.env` and fill values.',
      );
    }
    return v;
  }

  static String _opt(String key) => dotenv.env[key]?.trim() ?? '';

  static String get baseUrl => _opt('BASE_URL');

  /// Socket.IO namespace (`/ws`), e.g. `https://host/ws`.
  static String get socketUrl => _opt('SOCKET_URL');

  static String get googleMapsApiKey => _opt('GOOGLE_MAPS_API_KEY');
  static String get yandexMapsApiKey => _opt('YANDEX_MAPS_API_KEY');
  static String get stripePublishableKey => _opt('STRIPE_PUBLISHABLE_KEY');

  /// Backend endpoint that returns `{ "client_secret": "..." }` for PaymentIntent.
  static String get stripePaymentIntentUrl => _opt('STRIPE_PAYMENT_INTENT_URL');

  // ── Firebase (loaded into DefaultFirebaseOptions) ─────────────────────────
  static String get firebaseAndroidApiKey => _req('FIREBASE_ANDROID_API_KEY');
  static String get firebaseAndroidAppId => _req('FIREBASE_ANDROID_APP_ID');
  static String get firebaseMessagingSenderId => _req('FIREBASE_MESSAGING_SENDER_ID');
  static String get firebaseProjectId => _req('FIREBASE_PROJECT_ID');
  static String get firebaseStorageBucket => _req('FIREBASE_STORAGE_BUCKET');

  static String get firebaseIosApiKey => _req('FIREBASE_IOS_API_KEY');
  static String get firebaseIosAppId => _req('FIREBASE_IOS_APP_ID');
  static String get firebaseIosBundleId => _req('FIREBASE_IOS_BUNDLE_ID');
}

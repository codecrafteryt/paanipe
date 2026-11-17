import 'formatters.dart';

class Validators {
  Validators._();

  static String? phone(String? v) => normalizePkPhone(v ?? '') == null ? 'Enter a valid mobile number' : null;

  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  /// Same rule as the sendEmailOtp Cloud Function.
  static String? email(String? v) {
    final e = (v ?? '').trim();
    return e.length > 254 || !_email.hasMatch(e) ? 'Enter a valid email address' : null;
  }

  static String? required(String? v, [String message = 'Required']) =>
      (v ?? '').trim().isEmpty ? message : null;

  static String? minLength(String? v, int min, String message) =>
      (v ?? '').trim().length < min ? message : null;

  /// Number within [min, max] (matches firestore.rules limits).
  static String? range(String? v, num min, num max) {
    final n = num.tryParse(v ?? '');
    return n == null || n < min || n > max ? '$min – $max' : null;
  }

  static String? positiveInt(String? v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter a price' : null;
}

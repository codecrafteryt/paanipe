import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Result of asking for location. Only [deniedForever] / [serviceOff] need the Settings app.
enum LocationAccess { granted, denied, deniedForever, serviceOff }

class LocationService {
  LocationService._();

  /// Shows the native OS permission dialog when the user hasn't decided yet
  /// (iOS: Allow Once / While Using / Don't Allow · Android 12+: precise / approximate).
  static Future<LocationAccess> request() async {
    if (!await Geolocator.isLocationServiceEnabled()) return LocationAccess.serviceOff;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return switch (permission) {
      LocationPermission.whileInUse || LocationPermission.always => LocationAccess.granted,
      LocationPermission.deniedForever => LocationAccess.deniedForever,
      _ => LocationAccess.denied,
    };
  }

  /// Current state without prompting (safe to call on app resume).
  static Future<LocationAccess> status() async {
    if (!await Geolocator.isLocationServiceEnabled()) return LocationAccess.serviceOff;
    return switch (await Geolocator.checkPermission()) {
      LocationPermission.whileInUse || LocationPermission.always => LocationAccess.granted,
      LocationPermission.deniedForever => LocationAccess.deniedForever,
      _ => LocationAccess.denied,
    };
  }

  /// Opens the Settings screen that can fix [access] (app permissions, or device GPS).
  static Future<bool> openSettings(LocationAccess access) =>
      access == LocationAccess.serviceOff ? Geolocator.openLocationSettings() : Geolocator.openAppSettings();

  /// Current device position (asks for permission), or null when unavailable.
  static Future<Position?> current() async {
    if (await request() != LocationAccess.granted) return null;
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(timeLimit: Duration(seconds: 15)),
    );
  }

  /// First match for a typed place ("DHA Phase 5, Lahore"), or null when nothing matches.
  static Future<Location?> search(String query) async {
    try {
      final results = await Geocoding().locationFromAddress(query);
      return results.isEmpty ? null : results.first;
    } on Exception {
      return null; // "no result" is reported as an exception by the platform geocoder
    }
  }

  /// Short human-readable address; falls back to coordinates if geocoding fails.
  static Future<String> addressFor(double lat, double lng) async {
    final fallback = '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    try {
      final marks = await Geocoding().placemarkFromCoordinates(lat, lng);
      if (marks.isEmpty) return fallback;
      final p = marks.first;
      final parts = {
        p.name,
        p.subLocality,
        p.locality,
      }.whereType<String>().where((s) => s.trim().isNotEmpty && !s.contains('+'));
      return parts.isEmpty ? fallback : parts.join(', ');
    } on Exception {
      return fallback; // geocoder unavailable / offline — coordinates are still valid
    }
  }
}

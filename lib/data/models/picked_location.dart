import 'package:cloud_firestore/cloud_firestore.dart';

class PickedLocation {
  const PickedLocation(this.lat, this.lng, this.address);

  final double lat;
  final double lng;
  final String address;

  GeoPoint get geoPoint => GeoPoint(lat, lng);

  factory PickedLocation.fromGeoPoint(GeoPoint p, String address) =>
      PickedLocation(p.latitude, p.longitude, address);
}

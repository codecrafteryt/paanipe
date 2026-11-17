import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/helpers/delivery_fee.dart';
import '../../utils/helpers/formatters.dart';
import '../../utils/helpers/parse.dart';

class StoreModel {
  const StoreModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.address,
    required this.freeWithinKm,
    required this.chargePerKm,
  });

  /// Same as the owner's uid (one store per seller).
  final String id;
  final String name;
  final String phone;
  final String description;
  final String imageUrl;
  final GeoPoint location;
  final String address;
  final double freeWithinKm;
  final double chargePerKm;

  /// "Lahore, Pakistan".
  String get cityCountry => cityCountryOf(address);

  double distanceTo(GeoPoint p) =>
      DeliveryFee.distanceKm(p.latitude, p.longitude, location.latitude, location.longitude);

  int deliveryFeeTo(GeoPoint p) =>
      DeliveryFee.fee(distanceKm: distanceTo(p), freeWithinKm: freeWithinKm, chargePerKm: chargePerKm);

  String get feeRulesText => chargePerKm == 0
      ? 'Free delivery'
      : 'Free within ${trimNum(freeWithinKm)} km · Rs ${trimNum(chargePerKm)}/km after';

  factory StoreModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return StoreModel(
      id: doc.id,
      name: toStr(d['name']),
      phone: toStr(d['phone']),
      description: toStr(d['description']),
      imageUrl: toStr(d['imageUrl']),
      location: d['location'] is GeoPoint ? d['location'] as GeoPoint : const GeoPoint(0, 0),
      address: toStr(d['address']),
      freeWithinKm: toDouble(d['freeWithinKm']),
      chargePerKm: toDouble(d['chargePerKm']),
    );
  }

  /// `ownerId` is the doc id; firestore.rules enforce it equals the caller's uid.
  Map<String, dynamic> toMap() => {
    'ownerId': id,
    'name': name,
    'phone': phone,
    'description': description,
    'imageUrl': imageUrl,
    'location': location,
    'address': address,
    'freeWithinKm': freeWithinKm,
    'chargePerKm': chargePerKm,
  };
}

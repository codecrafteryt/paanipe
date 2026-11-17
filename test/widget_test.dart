import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paanipe/utils/helpers/delivery_fee.dart';
import 'package:paanipe/utils/helpers/formatters.dart';
import 'package:paanipe/utils/helpers/validators.dart';
import 'package:paanipe/data/models/store.dart';

void main() {
  group('DeliveryFee.fee', () {
    test('free inside the free range', () {
      expect(DeliveryFee.fee(distanceKm: 2.5, freeWithinKm: 3, chargePerKm: 20), 0);
      expect(DeliveryFee.fee(distanceKm: 3, freeWithinKm: 3, chargePerKm: 20), 0);
    });

    test('spec example: free within 3 km, Rs 20/km → 5 km = Rs 40', () {
      expect(DeliveryFee.fee(distanceKm: 5, freeWithinKm: 3, chargePerKm: 20), 40);
    });

    test('partial km is rounded up to the next rupee', () {
      expect(DeliveryFee.fee(distanceKm: 4.26, freeWithinKm: 3, chargePerKm: 20), 26);
    });
  });

  test('haversine distance Lahore → Islamabad ≈ 270 km', () {
    final d = DeliveryFee.distanceKm(31.5204, 74.3587, 33.6844, 73.0479);
    expect(d, closeTo(270, 10));
  });

  test('StoreModel.deliveryFeeTo uses store rules', () {
    final store = StoreModel(
      id: 's',
      name: 'Test',
      phone: '+923001234567',
      description: '',
      imageUrl: '',
      location: const GeoPoint(31.5204, 74.3587),
      address: '',
      freeWithinKm: 3,
      chargePerKm: 20,
    );
    expect(store.deliveryFeeTo(const GeoPoint(31.5204, 74.3587)), 0);
    // ~5 km north
    final fee = store.deliveryFeeTo(const GeoPoint(31.5654, 74.3587));
    expect(fee, inInclusiveRange(39, 41));
  });

  test('normalizePkPhone', () {
    expect(normalizePkPhone('03001234567'), '+923001234567');
    expect(normalizePkPhone('300 1234567'), '+923001234567');
    expect(normalizePkPhone('+92 300 1234567'), '+923001234567');
    expect(normalizePkPhone('12345'), isNull);
  });

  test('Validators.email matches the Cloud Function rule', () {
    expect(Validators.email('user@pannipe.com'), isNull);
    expect(Validators.email('  User@Mail.co  '), isNull);
    expect(Validators.email('user@pannipe'), isNotNull);
    expect(Validators.email('no-at-sign.com'), isNotNull);
    expect(Validators.email('${'a' * 250}@x.com'), isNotNull);
  });
}

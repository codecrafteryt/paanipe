import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../models/store.dart';

/// Demo stores + products placed around the user, so Explore → store → cart works
/// before real sellers join. Ids start with [prefix]; they are never written to Firestore.
class SampleCatalog {
  SampleCatalog._();

  static const prefix = 'sample_';
  static const _img = 'https://images.unsplash.com/photo-';
  static const _q = '?w=900&q=70&fit=crop';

  static const _bottleTable = '${_img}1523362628745-0c100150b504$_q';
  static const _glassBottle = '${_img}1559839914-17aae19cec71$_q';
  static const _pour = '${_img}1548839140-29a749e1cf4d$_q';
  static const _blueCap = '${_img}1616118132534-381148898bb4$_q';

  // name, description, area, cover, (dLat, dLng), freeWithinKm, chargePerKm
  static const _stores = [
    ('Aab-e-Hayat Water', 'Filtered RO water · 19 L refills in 30 min', 'Main Boulevard', _bottleTable, (0.006, 0.004), 3.0, 20.0),
    ('Blue Drop Mineral', 'Mineral water, sealed bottles and dispensers', 'Commercial Market', _blueCap, (-0.009, 0.007), 2.0, 25.0),
    ('Crystal Springs', 'Spring water delivered in glass bottles', 'Canal Road', _glassBottle, (0.013, -0.010), 5.0, 15.0),
    ('Pure Life Depot', 'Family packs and office supply, daily', 'Model Town Link Rd', _pour, (-0.016, -0.012), 1.0, 30.0),
    ('Nestle Point', 'Branded bottled water, all sizes', 'Liberty Chowk', _blueCap, (0.021, 0.015), 2.0, 20.0),
    ('Al-Madina Water Plant', 'Local plant · lowest price 19 L refills', 'Ferozepur Road', _bottleTable, (-0.004, -0.019), 4.0, 10.0),
  ];

  // name, size, price, image
  static const _menu = [
    ('Refill bottle', '19 L', 120, _blueCap),
    ('New bottle + water', '19 L', 950, _bottleTable),
    ('Mineral water', '1.5 L × 6', 540, _blueCap),
    ('Mineral water', '500 ml × 12', 600, _glassBottle),
    ('Glass bottle', '1 L', 250, _glassBottle),
    ('Water dispenser', 'Hot & cold', 18500, _pour),
  ];

  static final _byId = <String, StoreModel>{};

  static bool isSample(String id) => id.startsWith(prefix);

  static GeoPoint? _center;
  static String _area = '';
  static List<StoreModel> _around = const [];

  /// Demo stores offset from [c]. Same instances per center (list `indexOf` relies on it);
  /// cached by id so the detail screen can find them.
  static List<StoreModel> around(GeoPoint c, {String area = 'Lahore, Pakistan'}) {
    if (c != _center || area != _area) {
      _center = c;
      _area = area;
      _around = _build(c, area);
    }
    return _around;
  }

  static List<StoreModel> _build(GeoPoint c, String area) => [
    for (final (i, s) in _stores.indexed)
      _byId['$prefix$i'] = StoreModel(
        id: '$prefix$i',
        name: s.$1,
        phone: '0300123456$i',
        description: s.$2,
        address: '${s.$3}, $area',
        imageUrl: s.$4,
        location: GeoPoint(c.latitude + s.$5.$1, c.longitude + s.$5.$2),
        freeWithinKm: s.$6,
        chargePerKm: s.$7,
      ),
  ];

  static StoreModel? store(String id) => _byId[id];

  /// Each store gets a slightly different menu and price.
  static List<Product> products(String storeId) {
    final n = int.tryParse(storeId.replaceFirst(prefix, '')) ?? 0;
    return [
      for (final (i, m) in _menu.indexed)
        if ((i + n) % 5 != 4)
          Product(
            id: 'p$i',
            name: m.$1,
            size: m.$2,
            price: m.$3 + (m.$3 < 1000 ? n * 10 : 0),
            imageUrl: m.$4,
            inStock: (i + n) % 7 != 6,
          ),
    ];
  }
}

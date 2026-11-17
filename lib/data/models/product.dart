import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/helpers/parse.dart';

class Product {
  const Product({
    this.id = '',
    required this.name,
    required this.size,
    required this.price,
    required this.imageUrl,
    required this.inStock,
  });

  /// Empty for a product that is not saved yet.
  final String id;
  final String name;

  /// e.g. "19 L bottle".
  final String size;
  final int price;
  final String imageUrl;
  final bool inStock;

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Product(
      id: doc.id,
      name: toStr(d['name']),
      size: toStr(d['size']),
      price: toInt(d['price']),
      imageUrl: toStr(d['imageUrl']),
      inStock: d['inStock'] != false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'size': size,
    'price': price,
    'imageUrl': imageUrl,
    'inStock': inStock,
  };
}

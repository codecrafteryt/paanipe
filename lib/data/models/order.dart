import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/helpers/parse.dart';
import 'order_status.dart';

export 'order_status.dart';

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.size,
    required this.price,
    required this.qty,
  });

  final String productId;
  final String name;
  final String size;
  final int price;
  final int qty;

  int get lineTotal => price * qty;
  String get label => '$qty × $name${size.isEmpty ? '' : ' ($size)'}';

  OrderItem withQty(int q) => OrderItem(productId: productId, name: name, size: size, price: price, qty: q);

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
    productId: toStr(m['productId']),
    name: toStr(m['name']),
    size: toStr(m['size']),
    price: toInt(m['price']),
    qty: toInt(m['qty'], 1),
  );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'name': name,
    'size': size,
    'price': price,
    'qty': qty,
  };
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.storeName,
    required this.storePhone,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.distanceKm,
    required this.total,
    required this.deliveryLocation,
    required this.deliveryAddress,
    required this.note,
    required this.status,
    required this.createdAt,
    required this.cancelReason,
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final String storeName;
  final String storePhone;
  final List<OrderItem> items;
  final int subtotal;
  final int deliveryFee;
  final double distanceKm;
  final int total;
  final GeoPoint deliveryLocation;
  final String deliveryAddress;
  final String note;
  final OrderStatus status;
  final DateTime? createdAt;
  final String cancelReason;

  String get shortId => id.substring(0, 6).toUpperCase();
  String get itemsSummary => items.map((i) => '${i.qty}× ${i.name}').join(', ');

  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return OrderModel(
      id: doc.id,
      customerName: toStr(d['customerName']),
      customerPhone: toStr(d['customerPhone']),
      storeName: toStr(d['storeName']),
      storePhone: toStr(d['storePhone']),
      items: (d['items'] as List? ?? const [])
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      subtotal: toInt(d['subtotal']),
      deliveryFee: toInt(d['deliveryFee']),
      distanceKm: toDouble(d['distanceKm']),
      total: toInt(d['total']),
      deliveryLocation: d['deliveryLocation'] is GeoPoint
          ? d['deliveryLocation'] as GeoPoint
          : const GeoPoint(0, 0),
      deliveryAddress: toStr(d['deliveryAddress']),
      note: toStr(d['note']),
      status: OrderStatus.from(toStr(d['status'])),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      cancelReason: toStr(d['cancelReason']),
    );
  }
}

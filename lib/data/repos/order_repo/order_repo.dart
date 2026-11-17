import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../models/order.dart';

class OrderRepo extends GetxService {
  final _orders = FirebaseFirestore.instance.collection(Constants.orders);

  Stream<List<OrderModel>> _list(String field, String uid) => _orders
      .where(field, isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map(OrderModel.fromDoc).toList());

  Stream<List<OrderModel>> customerOrders(String uid) => _list('customerId', uid);

  Stream<List<OrderModel>> storeOrders(String storeId) => _list('storeId', storeId);

  Stream<OrderModel?> order(String id) =>
      _orders.doc(id).snapshots().map((d) => d.exists ? OrderModel.fromDoc(d) : null);

  /// `onOrderCreated` (Cloud Function) re-verifies prices + fee and notifies the seller.
  Future<String> placeOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String storeId,
    required String storeName,
    required String storePhone,
    required List<OrderItem> items,
    required int subtotal,
    required int deliveryFee,
    required double distanceKm,
    required GeoPoint deliveryLocation,
    required String deliveryAddress,
    required String note,
  }) async {
    final ref = _orders.doc();
    await ref.set({
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'storeId': storeId,
      'storeName': storeName,
      'storePhone': storePhone,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'distanceKm': double.parse(distanceKm.toStringAsFixed(1)),
      'total': subtotal + deliveryFee,
      'paymentMethod': 'cod',
      'deliveryLocation': deliveryLocation,
      'deliveryAddress': deliveryAddress,
      'note': note,
      'status': OrderStatus.placed.value,
      'statusTimes': {OrderStatus.placed.value: FieldValue.serverTimestamp()},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updateStatus(String orderId, OrderStatus status, {String? reason}) =>
      _orders.doc(orderId).update({
        'status': status.value,
        'statusTimes.${status.value}': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'cancelReason': ?reason,
      });
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../models/product.dart';
import '../../models/store.dart';

class StoreRepo extends GetxService {
  final _stores = FirebaseFirestore.instance.collection(Constants.stores);

  CollectionReference<Map<String, dynamic>> _products(String storeId) =>
      _stores.doc(storeId).collection(Constants.products);

  Stream<List<StoreModel>> allStores() =>
      _stores.snapshots().map((s) => s.docs.map(StoreModel.fromDoc).toList());

  Stream<StoreModel?> store(String id) =>
      _stores.doc(id).snapshots().map((d) => d.exists ? StoreModel.fromDoc(d) : null);

  Future<void> saveStore(StoreModel store, {required bool isNew}) => _stores.doc(store.id).set({
    ...store.toMap(),
    'updatedAt': FieldValue.serverTimestamp(),
    if (isNew) 'createdAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  Future<void> setOpen(String storeId, bool open) => _stores.doc(storeId).update({'isOpen': open});

  Stream<List<Product>> products(String storeId) =>
      _products(storeId).orderBy('createdAt').snapshots().map((s) => s.docs.map(Product.fromDoc).toList());

  Future<void> saveProduct(String storeId, Product p) => p.id.isEmpty
      ? _products(storeId).add({...p.toMap(), 'createdAt': FieldValue.serverTimestamp()})
      : _products(storeId).doc(p.id).set(p.toMap(), SetOptions(merge: true));

  Future<void> setInStock(String storeId, String productId, bool inStock) =>
      _products(storeId).doc(productId).update({'inStock': inStock});

  Future<void> deleteProduct(String storeId, String productId) => _products(storeId).doc(productId).delete();

  /// Uploads to `stores/{ownerUid}/{name}.jpg` (see storage.rules) and returns the URL.
  Future<String> uploadImage(String ownerUid, String name, File file) async {
    final ref = FirebaseStorage.instance.ref('${Constants.stores}/$ownerUid/$name.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}

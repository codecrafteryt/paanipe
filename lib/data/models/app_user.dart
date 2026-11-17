import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/helpers/formatters.dart';
import '../../utils/helpers/parse.dart';

class AppUser {
  const AppUser({required this.uid, required this.email, required this.name, required this.phone});

  final String uid;
  final String email;
  final String name;

  /// Delivery contact number (stores call this); not used for sign-in.
  final String phone;

  /// Orders need a name and a reachable mobile number.
  bool get hasProfile => name.trim().length >= 2 && normalizePkPhone(phone) != null;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return AppUser(uid: doc.id, email: toStr(d['email']), name: toStr(d['name']), phone: toStr(d['phone']));
  }
}

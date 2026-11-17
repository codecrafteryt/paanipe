import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controller/order_detail_controller.dart';
import '../data/constants.dart';
import '../firebase_options.dart';

/// Background/terminated messages carry a `notification` payload, so the OS shows them.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) =>
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

/// FCM token ↔ `users/{uid}.fcmTokens`, foreground popups, tap → order screen.
class NotificationService extends GetxService {
  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();
  final _users = FirebaseFirestore.instance.collection(Constants.users);
  StreamSubscription<String>? _refreshSub;

  static const _channel = AndroidNotificationChannel(
    Constants.ordersChannelId,
    'Orders',
    description: 'New orders and order status updates',
    importance: Importance.high,
  );

  Future<void> init() async {
    try {
      await _local.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (r) =>
            _openOrder(Map<String, dynamic>.from(jsonDecode(r.payload ?? '{}') as Map)),
      );
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
      await _messaging.requestPermission();
      if (Platform.isAndroid) await Permission.notification.request();

      FirebaseMessaging.onMessage.listen(_showForeground);
      FirebaseMessaging.onMessageOpenedApp.listen((m) => _openOrder(m.data));
      final initial = await _messaging.getInitialMessage();
      if (initial != null) _openOrder(initial.data);
    } catch (e) {
      debugPrint('NotificationService.init failed: $e'); // push is optional; app still works
    }
  }

  void _openOrder(Map<String, dynamic> data) {
    final orderId = data['orderId']?.toString();
    if (orderId == null || orderId.isEmpty) return;
    OrderDetailController.open(orderId, asSeller: data['mode'] == 'seller');
  }

  Future<void> _showForeground(RemoteMessage m) async {
    final n = m.notification;
    if (n == null) return;
    await _local.show(
      m.hashCode & 0x7fffffff,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(m.data),
    );
  }

  Future<void> registerToken(String uid) async {
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(uid, token);
    await _refreshSub?.cancel();
    _refreshSub = _messaging.onTokenRefresh.listen((t) => _saveToken(uid, t));
  }

  Future<void> _saveToken(String uid, String token) => _users.doc(uid).set({
    'fcmTokens': FieldValue.arrayUnion([token]),
  }, SetOptions(merge: true));

  Future<void> unregisterToken(String uid) async {
    await _refreshSub?.cancel();
    final token = await _messaging.getToken();
    if (token == null) return;
    await _users.doc(uid).update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }
}

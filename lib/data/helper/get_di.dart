import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/auth_controller.dart';
import '../../controller/cart_controller.dart';
import '../../controller/checkout_controller.dart';
import '../../controller/customer_orders_controller.dart';
import '../../controller/explore_controller.dart';
import '../../controller/explore_map_controller.dart';
import '../../controller/explore_search_controller.dart';
import '../../controller/home_controller.dart';
import '../../controller/location_controller.dart';
import '../../controller/nav_controller.dart';
import '../../controller/seller_controller.dart';
import '../../firebase_options.dart';
import '../../service/notification_service.dart';
import '../repos/auth_repo/auth_repo.dart';
import '../repos/order_repo/order_repo.dart';
import '../repos/store_repo/store_repo.dart';

class DependencyInjection {
  DependencyInjection._();

  static Future<void> init() async {
    // Secrets first — Firebase options + maps keys come from `.env`.
    await dotenv.load(fileName: '.env');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    final prefs = await SharedPreferences.getInstance();

    Get.put<SharedPreferences>(prefs, permanent: true);

    // Repositories & services
    Get.put(AuthRepo(), permanent: true);
    Get.put(StoreRepo(), permanent: true);
    Get.put(OrderRepo(), permanent: true);
    Get.put(NotificationService(), permanent: true);

    // App-wide controllers
    Get.put(AuthController(authRepo: Get.find(), prefs: prefs), permanent: true);
    Get.put(LocationController(prefs: prefs), permanent: true);
    Get.put(CartController(), permanent: true);

    // Shell controllers (created on first use)
    Get.lazyPut(() => NavController(collapsibleIndex: 0), tag: NavController.customer, fenix: true);
    Get.lazyPut(NavController.new, tag: NavController.seller, fenix: true);
    Get.lazyPut(CheckoutController.new, fenix: true);
    Get.lazyPut(() => HomeController(storeRepo: Get.find()), fenix: true);
    Get.lazyPut(ExploreController.new, fenix: true);
    Get.lazyPut(ExploreMapController.new, fenix: true);
    Get.lazyPut(ExploreSearchController.new, fenix: true);
    Get.lazyPut(() => CustomerOrdersController(orderRepo: Get.find()), fenix: true);
    Get.lazyPut(() => SellerController(storeRepo: Get.find(), orderRepo: Get.find()), fenix: true);

    unawaited(Get.find<NotificationService>().init());
  }
}

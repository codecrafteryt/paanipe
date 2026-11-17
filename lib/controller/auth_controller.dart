import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/constants.dart';
import '../data/models/app_user.dart';
import '../data/repos/auth_repo/auth_repo.dart';
import '../service/notification_service.dart';
import '../utils/helpers/app_messages.dart';
import '../utils/helpers/formatters.dart';
import '../utils/helpers/validators.dart';
import '../views/auth/login_sheet.dart';
import '../views/auth/otp_sheet.dart';
import '../views/auth/profile_setup_sheet.dart';
import '../views/widgets/app_loader.dart';
import '../views/widgets/app_sheet/app_bottom_sheet.dart';
import 'cart_controller.dart';

enum AppMode { customer, seller }

enum SessionState { loading, guest, needsProfile, ready }

/// Session (Firebase Auth + users doc), email-code / Google sign-in, profile, mode.
class AuthController extends GetxController {
  AuthController({required this.authRepo, required this.prefs});

  final AuthRepo authRepo;
  final SharedPreferences prefs;

  final profile = Rxn<AppUser>();
  final state = SessionState.loading.obs;
  late final mode = AppMode.values.byName(prefs.getString(Constants.appMode) ?? 'customer').obs;

  final emailCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final isSending = false.obs;
  final isVerifying = false.obs;
  final isGoogleLoading = false.obs;
  final isSaving = false.obs;
  final secondsLeft = 0.obs;

  /// Email the current code was sent to.
  String email = '';
  Timer? _timer;
  StreamSubscription<AppUser?>? _profileSub;
  final _settled = Completer<void>();

  String? get uid => FirebaseAuth.instance.currentUser?.uid;
  bool get isLoggedIn => state.value == SessionState.ready;
  bool get isSeller => isLoggedIn && mode.value == AppMode.seller;

  /// Completes once the first auth state is known (cold-start deep links wait on it).
  Future<void> get settled => _settled.future;

  @override
  void onInit() {
    super.onInit();
    authRepo.authChanges().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    await _profileSub?.cancel();
    profile.value = null;
    if (user == null) return _setState(SessionState.guest);
    try {
      await authRepo.reloadUser(); // drops cached sessions of disabled / deleted accounts
    } on FirebaseAuthException catch (e) {
      if (const {'user-disabled', 'user-not-found', 'user-token-expired'}.contains(e.code)) {
        return authRepo.signOut();
      }
      // Offline etc.: keep the cached session; Firestore rules still enforce access.
    }
    _profileSub = authRepo.userStream(user.uid).listen((p) {
      if (p == null) {
        authRepo.createUser(user); // first sign-in; the next snapshot carries the doc
        return;
      }
      profile.value = p;
      _setState(p.hasProfile ? SessionState.ready : SessionState.needsProfile);
    }, onError: (Object e) => showError('Could not load your account. Please try again.'));
    Get.find<NotificationService>().registerToken(user.uid).catchError((Object _) {});
  }

  void _setState(SessionState s) {
    state.value = s;
    if (!_settled.isCompleted) _settled.complete();
  }

  /// Waits until a fresh sign-in has a resolved profile state.
  Future<void> _awaitSignedIn() async {
    if (state.value == SessionState.ready || state.value == SessionState.needsProfile) return;
    await state.stream
        .firstWhere((s) => s == SessionState.ready || s == SessionState.needsProfile)
        .timeout(const Duration(seconds: 20));
  }

  // ── Guest gate: login sheet → code sheet → finish-profile sheet ──────────────
  Future<bool> requireLogin() async {
    if (isLoggedIn) return true;
    if (state.value != SessionState.needsProfile && await _sheet<bool>(const LoginSheet()) == true) {
      await _sheet<void>(const OtpSheet());
    }
    if (state.value == SessionState.needsProfile) {
      nameCtrl.text = profile.value?.name ?? '';
      phoneCtrl.text = localPhone(profile.value?.phone ?? '');
      await _sheet<void>(const ProfileSetupSheet());
    }
    return isLoggedIn;
  }

  /// Auth sheets run from just under the status bar to the bottom of the screen.
  Future<T?> _sheet<T>(Widget child) async {
    final context = Get.context;
    if (context == null) return null;
    final size = MediaQuery.sizeOf(context).height;
    final topGap = MediaQuery.paddingOf(context).top + 8;
    return showAppModalBottomSheet<T>(
      context: context,
      child: child,
      topRadius: 20,
      maxHeightFactor: (size - topGap) / size,
    );
  }

  /// Login sheet "Continue": email a code, then the sheet closes into the code sheet.
  Future<void> sendCode() async {
    final error = Validators.email(emailCtrl.text);
    if (error != null) return showError(error);
    if (await _send(emailCtrl.text.trim().toLowerCase())) Get.back(result: true);
  }

  Future<void> resendCode() async {
    if (secondsLeft.value == 0 && await _send(email)) showOk('A new code is on its way.');
  }

  Future<bool> _send(String to) async {
    isSending.value = true;
    try {
      await authRepo.sendEmailCode(to);
      email = to;
      codeCtrl.clear();
      _startTimer();
      return true;
    } catch (e) {
      showError(AuthRepo.messageFor(e));
      return false;
    } finally {
      isSending.value = false;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    secondsLeft.value = Constants.otpResendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (--secondsLeft.value <= 0) t.cancel();
    });
  }

  Future<void> verifyCode() async {
    if (codeCtrl.text.length != Constants.otpLength || isVerifying.value) return;
    isVerifying.value = true;
    try {
      await authRepo.verifyEmailCode(email, codeCtrl.text);
      await _finishSignIn();
    } catch (e) {
      codeCtrl.clear();
      showError(AuthRepo.messageFor(e));
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    if (isGoogleLoading.value) return;
    isGoogleLoading.value = true;
    try {
      if (await authRepo.signInWithGoogle()) await _finishSignIn();
    } catch (e) {
      showError(AuthRepo.messageFor(e));
    } finally {
      isGoogleLoading.value = false;
    }
  }

  /// Full-screen loader until the account resolves, then close the auth sheet.
  Future<void> _finishSignIn() async {
    AppLoader.show();
    try {
      await _awaitSignedIn();
    } on TimeoutException {
      await authRepo.signOut();
      throw FirebaseAuthException(code: 'timeout', message: 'Could not load your account. Please try again.');
    } finally {
      AppLoader.hide();
    }
    Get.back<void>();
  }

  // ── Profile ──────────────────────────────────────────────────────────────────
  Future<void> saveProfile() async {
    final id = uid;
    final name = nameCtrl.text.trim();
    final phone = normalizePkPhone(phoneCtrl.text);
    if (id == null) return;
    if (name.length < 2) return showError('Please enter your name');
    if (phone == null) return showError('Enter a valid mobile number, e.g. 0300 1234567');
    isSaving.value = true;
    try {
      await authRepo.updateProfile(id, name: name, phone: phone);
      await state.stream.firstWhere((s) => s == SessionState.ready).timeout(const Duration(seconds: 10));
      Get.back<void>();
    } catch (e) {
      showError('Could not save your details. Please try again.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> editName() async {
    final p = profile.value;
    final name = await inputDialog('Your name', initial: p?.name ?? '');
    if (p == null || name == null || name.length < 2) return;
    await authRepo.updateProfile(p.uid, name: name, phone: p.phone);
  }

  Future<void> switchMode(AppMode m) async {
    if (m == AppMode.seller && !await requireLogin()) return;
    mode.value = m;
    await prefs.setString(Constants.appMode, m.name);
    Get.until((r) => r.isFirst);
  }

  /// Ends the session everywhere on this device: push token, Google, Firebase, local state.
  Future<void> signOut() async {
    final id = uid;
    if (id == null) return;
    if (!await confirmDialog('Log out?', 'You can keep browsing as a guest.', ok: 'Log out')) return;
    await Get.find<NotificationService>().unregisterToken(id).catchError((Object _) {});
    await switchMode(AppMode.customer);
    await authRepo.signOut();
    Get.find<CartController>().clear();
    for (final c in [emailCtrl, codeCtrl, nameCtrl, phoneCtrl]) {
      c.clear();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    _profileSub?.cancel();
    super.onClose();
  }
}

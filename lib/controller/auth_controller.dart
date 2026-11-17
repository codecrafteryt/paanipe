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
import '../views/auth/profile_setup_sheet.dart';
import '../views/widgets/app_loader.dart';
import '../views/widgets/app_sheet/app_bottom_sheet.dart';
import 'cart_controller.dart';

enum AppMode { customer, seller }

enum SessionState { loading, guest, needsProfile, ready }

/// Session (Firebase Auth + users doc), email/password + Google, slim profile, mode.
class AuthController extends GetxController {
  AuthController({required this.authRepo, required this.prefs});

  final AuthRepo authRepo;
  final SharedPreferences prefs;

  final profile = Rxn<AppUser>();
  final state = SessionState.loading.obs;
  late final mode = AppMode.values.byName(prefs.getString(Constants.appMode) ?? 'customer').obs;

  /// `true` = create account, `false` = sign in.
  final isRegisterMode = false.obs;
  final obscurePassword = true.obs;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final isAuthLoading = false.obs;
  final isGoogleLoading = false.obs;
  final isSaving = false.obs;

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
      await authRepo.reloadUser();
    } on FirebaseAuthException catch (e) {
      if (const {'user-disabled', 'user-not-found', 'user-token-expired'}.contains(e.code)) {
        return authRepo.signOut();
      }
    }
    _profileSub = authRepo.userStream(user.uid).listen((p) {
      if (p == null) {
        authRepo.createUser(user);
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

  Future<void> _awaitSignedIn() async {
    if (state.value == SessionState.ready || state.value == SessionState.needsProfile) return;
    await state.stream
        .firstWhere((s) => s == SessionState.ready || s == SessionState.needsProfile)
        .timeout(const Duration(seconds: 20));
  }

  // ── Guest gate: login sheet → finish-profile sheet ─────────────────────────
  Future<bool> requireLogin() async {
    if (isLoggedIn) return true;
    if (state.value != SessionState.needsProfile) {
      await _sheet<bool>(const LoginSheet());
    }
    if (state.value == SessionState.needsProfile) {
      nameCtrl.text = profile.value?.name ?? '';
      phoneCtrl.text = localPhone(profile.value?.phone ?? '');
      await _sheet<void>(const ProfileSetupSheet());
    }
    return isLoggedIn;
  }

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

  void toggleAuthMode() => isRegisterMode.toggle();

  void toggleObscurePassword() => obscurePassword.toggle();

  /// Login / register with email + password, then close into profile if needed.
  Future<void> submitEmailAuth() async {
    final emailError = Validators.email(emailCtrl.text);
    if (emailError != null) return showError(emailError);
    final passwordError = Validators.password(passwordCtrl.text);
    if (passwordError != null) return showError(passwordError);

    if (isAuthLoading.value) return;
    isAuthLoading.value = true;
    try {
      final email = emailCtrl.text.trim().toLowerCase();
      final password = passwordCtrl.text;
      if (isRegisterMode.value) {
        await authRepo.registerWithEmailPassword(email: email, password: password);
      } else {
        await authRepo.signInWithEmailPassword(email: email, password: password);
      }
      await _finishSignIn();
    } catch (e) {
      showError(AuthRepo.messageFor(e));
    } finally {
      isAuthLoading.value = false;
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

  Future<void> _finishSignIn() async {
    AppLoader.show();
    try {
      await _awaitSignedIn();
    } on TimeoutException {
      await authRepo.signOut();
      throw FirebaseAuthException(
        code: 'timeout',
        message: 'Could not load your account. Please try again.',
      );
    } finally {
      AppLoader.hide();
    }
    Get.back(result: true);
  }

  // ── Profile (name + delivery mobile only) ──────────────────────────────────
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

  Future<void> signOut() async {
    final id = uid;
    if (id == null) return;
    if (!await confirmDialog('Log out?', 'You can keep browsing as a guest.', ok: 'Log out')) return;
    await Get.find<NotificationService>().unregisterToken(id).catchError((Object _) {});
    await switchMode(AppMode.customer);
    await authRepo.signOut();
    Get.find<CartController>().clear();
    for (final c in [emailCtrl, passwordCtrl, nameCtrl, phoneCtrl]) {
      c.clear();
    }
    isRegisterMode.value = false;
  }

  @override
  void onClose() {
    _profileSub?.cancel();
    super.onClose();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../constants.dart';
import '../../models/app_user.dart';
import '../../../utils/values/env.dart';

/// Email/password + Google Sign-In, plus the `users/{uid}` Firestore profile.
class AuthRepo extends GetxService {
  final _auth = FirebaseAuth.instance;
  final _users = FirebaseFirestore.instance.collection(Constants.users);
  final _google = GoogleSignIn.instance;
  Future<void>? _googleInit;

  Stream<User?> authChanges() => _auth.authStateChanges();

  /// Emits null until the user doc exists.
  Stream<AppUser?> userStream(String uid) =>
      _users.doc(uid).snapshots().map((d) => d.exists ? AppUser.fromDoc(d) : null);

  /// First sign-in: seed the doc from the auth account (Google may give a display name).
  Future<void> createUser(User user) => _users.doc(user.uid).set({
        'email': user.email ?? '',
        'name': user.displayName?.trim() ?? '',
        'phone': '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  Future<void> updateProfile(String uid, {required String name, required String phone}) =>
      _users.doc(uid).update({'name': name, 'phone': phone});

  /// Server re-checks the account; throws if it was disabled or deleted.
  Future<void> reloadUser() async => _auth.currentUser?.reload();

  Future<void> signInWithEmailPassword({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> registerWithEmailPassword({required String email, required String password}) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> _ensureGoogleInit() {
    return _googleInit ??= () async {
      final webClientId = Env.googleWebClientId;
      if (webClientId.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-web-client-id',
          message:
              'Add GOOGLE_WEB_CLIENT_ID to `.env` (Firebase → Authentication → Google → Web client ID).',
        );
      }
      await _google.initialize(serverClientId: webClientId);
    }();
  }

  /// False when the user closed the Google account picker.
  Future<bool> signInWithGoogle() async {
    await _ensureGoogleInit();
    try {
      final account = await _google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw FirebaseAuthException(code: 'missing-google-id-token');
      await _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
      rethrow;
    }
  }

  /// Clears Firebase and Google sessions (so the account picker shows next time).
  Future<void> signOut() async {
    if (_googleInit != null) await _google.signOut();
    await _auth.signOut();
  }

  /// Short, user-facing message for any auth error.
  static String messageFor(Object e) {
    final raw = e.toString();
    if (raw.contains('CONFIGURATION_NOT_FOUND')) {
      return 'Firebase Auth is not set up yet. Open Firebase Console → Authentication → Get started.';
    }
    return switch (e) {
      FirebaseAuthException(code: 'user-disabled') => 'This account has been disabled.',
      FirebaseAuthException(code: 'user-not-found') ||
      FirebaseAuthException(code: 'wrong-password') ||
      FirebaseAuthException(code: 'invalid-credential') =>
        'Incorrect email or password.',
      FirebaseAuthException(code: 'email-already-in-use') =>
        'An account already exists with this email. Sign in instead.',
      FirebaseAuthException(code: 'weak-password') => 'Password must be at least 6 characters.',
      FirebaseAuthException(code: 'invalid-email') => 'Enter a valid email address.',
      FirebaseAuthException(code: 'too-many-requests') => 'Too many attempts. Try again later.',
      FirebaseAuthException(code: 'network-request-failed') => 'No internet connection.',
      FirebaseAuthException(code: 'account-exists-with-different-credential') =>
        'This email is already linked to another sign-in method.',
      FirebaseAuthException(code: 'missing-web-client-id') =>
        'Google Sign-In is not configured. Add GOOGLE_WEB_CLIENT_ID to .env.',
      FirebaseAuthException(:final message?) when message.isNotEmpty => message,
      GoogleSignInException(:final description?) => 'Google sign-in failed: $description',
      _ => 'Something went wrong. Please try again.',
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../constants.dart';
import '../../models/app_user.dart';

/// Sign-in via email one-time code (Cloud Functions) or Google, plus the `users/{uid}` doc.
class AuthRepo extends GetxService {
  final _auth = FirebaseAuth.instance;
  final _users = FirebaseFirestore.instance.collection(Constants.users);
  final _functions = FirebaseFunctions.instanceFor(region: Constants.functionsRegion);
  final _google = GoogleSignIn.instance;
  Future<void>? _googleInit;

  Stream<User?> authChanges() => _auth.authStateChanges();

  /// Emits null until the user doc exists.
  Stream<AppUser?> userStream(String uid) =>
      _users.doc(uid).snapshots().map((d) => d.exists ? AppUser.fromDoc(d) : null);

  /// First sign-in: seed the doc from the auth account (Google gives a display name).
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

  Future<void> sendEmailCode(String email) =>
      _functions.httpsCallable('sendEmailOtp').call<void>({'email': email});

  Future<void> verifyEmailCode(String email, String code) async {
    final result = await _functions.httpsCallable('verifyEmailOtp').call<Map<String, dynamic>>({
      'email': email,
      'code': code,
    });
    final token = result.data['token'];
    if (token is! String) throw FirebaseAuthException(code: 'invalid-custom-token');
    await _auth.signInWithCustomToken(token);
  }

  /// False when the user closed the Google account picker.
  Future<bool> signInWithGoogle() async {
    await (_googleInit ??= _google.initialize());
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

  /// Short, user-facing message for any auth / function error.
  static String messageFor(Object e) => switch (e) {
    FirebaseFunctionsException(:final message?) when message.isNotEmpty => message,
    FirebaseAuthException(code: 'user-disabled') => 'This account has been disabled.',
    FirebaseAuthException(code: 'network-request-failed') => 'No internet connection.',
    FirebaseAuthException(code: 'account-exists-with-different-credential') =>
      'This email is already linked to another sign-in method.',
    FirebaseAuthException(:final message?) => message,
    GoogleSignInException(:final description?) => 'Google sign-in failed: $description',
    _ => 'Something went wrong. Please try again.',
  };
}

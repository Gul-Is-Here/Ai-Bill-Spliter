import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/functions_client.dart';
import '../models/app_user.dart';

/// All FirebaseAuth / Google Sign-In calls live here.
class AuthRepository {
  AuthRepository(
    this._functions, {
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _google = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _google;
  final FunctionsClient _functions;
  Future<void>? _googleInit;

  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : AppUser.fromFirebase(user);
  }

  Future<AppUser> signInWithEmail(String email, String password) =>
      _guard(() => _auth.signInWithEmailAndPassword(email: email, password: password));

  Future<AppUser> registerWithEmail(String name, String email, String password) => _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        await cred.user!.updateDisplayName(name);
        await cred.user!.reload();
        return cred;
      });

  Future<AppUser> signInWithGoogle() => _guard(() async {
        await (_googleInit ??= _google.initialize());
        final account = await _google.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null) throw const AppException('error_google_sign_in');
        return _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
      });

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await (_googleInit ??= _google.initialize());
      await _google.signOut();
    } catch (_) {
      // Google session may not exist (email user); Firebase sign-out already succeeded.
    }
  }

  /// Server deletes Firestore data, Storage files and the Auth user (Play account-deletion requirement).
  Future<void> deleteAccount() async {
    await _functions.call('deleteAccount', const {}, maxAttempts: 1);
    await signOut();
  }

  Future<AppUser> _guard(Future<UserCredential> Function() action) async {
    try {
      final cred = await action();
      final user = AppUser.fromFirebase(_auth.currentUser ?? cred.user!);
      await _firestore.collection('users').doc(user.uid).set({
        ...user.toJson(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return user;
    } catch (e) {
      throw AppException.from(e);
    }
  }
}

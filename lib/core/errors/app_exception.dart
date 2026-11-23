import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// User-facing error. [messageKey] is a translation key.
class AppException implements Exception {
  const AppException(this.messageKey, {this.cancelled = false});

  final String messageKey;

  /// True when the user backed out (e.g. closed the Google picker); show nothing.
  final bool cancelled;

  String get message => messageKey.tr;

  factory AppException.from(Object error) {
    if (error is AppException) return error;
    if (error is TimeoutException) return const AppException('error_timeout');
    if (error is GoogleSignInException) {
      return error.code == GoogleSignInExceptionCode.canceled
          ? const AppException('error_generic', cancelled: true)
          : const AppException('error_google_sign_in');
    }
    if (error is FirebaseFunctionsException) {
      return switch (error.code) {
        'resource-exhausted' => const AppException('error_rate_limited'),
        // Signed in but still rejected = App Check (device verification) failed, not the session.
        'unauthenticated' => FirebaseAuth.instance.currentUser == null
            ? const AppException('error_session_expired')
            : const AppException('error_device_check'),
        'deadline-exceeded' => const AppException('error_timeout'),
        'unavailable' => const AppException('error_network'),
        'invalid-argument' || 'failed-precondition' => const AppException('error_invalid_response'),
        _ => const AppException('error_generic'),
      };
    }
    if (error is FirebaseException) {
      return switch (error.code) {
        'invalid-email' => const AppException('error_invalid_email'),
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          const AppException('error_wrong_credentials'),
        'email-already-in-use' => const AppException('error_email_in_use'),
        'weak-password' => const AppException('error_weak_password'),
        'too-many-requests' => const AppException('error_rate_limited'),
        'network-request-failed' || 'unavailable' => const AppException('error_network'),
        'requires-recent-login' => const AppException('error_session_expired'),
        _ => const AppException('error_generic'),
      };
    }
    return const AppException('error_generic');
  }
}

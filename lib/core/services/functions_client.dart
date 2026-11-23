import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';

import '../errors/app_exception.dart';

/// Calls Cloud Functions with a timeout and retries on transient failures only.
class FunctionsClient {
  FunctionsClient({FirebaseFunctions? functions}) : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  static const _retryable = {'unavailable', 'deadline-exceeded', 'internal'};

  Future<Map<String, dynamic>> call(
    String name,
    Map<String, dynamic> data, {
    Duration timeout = const Duration(seconds: 60),
    int maxAttempts = 3,
  }) async {
    final callable = _functions.httpsCallable(name, options: HttpsCallableOptions(timeout: timeout));
    for (var attempt = 1;; attempt++) {
      try {
        final result = await callable.call<Map<String, dynamic>>(data).timeout(timeout + const Duration(seconds: 5));
        return Map<String, dynamic>.from(result.data);
      } on FirebaseFunctionsException catch (e) {
        if (!_retryable.contains(e.code) || attempt >= maxAttempts) throw AppException.from(e);
      } on TimeoutException catch (e) {
        if (attempt >= maxAttempts) throw AppException.from(e);
      }
      await Future<void>.delayed(Duration(seconds: 1 << attempt)); // 2s, 4s backoff
    }
  }
}

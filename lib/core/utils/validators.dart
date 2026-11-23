import 'package:get/get.dart';

/// Form validators returning translated messages (null = valid).
abstract class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? v) =>
      v != null && _email.hasMatch(v.trim()) ? null : 'error_invalid_email'.tr;

  static String? password(String? v) => (v?.length ?? 0) >= 6 ? null : 'error_weak_password'.tr;

  static String? required(String? v) => (v?.trim().isEmpty ?? true) ? 'error_required'.tr : null;
}

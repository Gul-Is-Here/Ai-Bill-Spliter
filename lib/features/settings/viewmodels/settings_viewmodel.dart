import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/local_cache_service.dart';
import '../../auth/repositories/auth_repository.dart';
import '../repositories/settings_repository.dart';

class SettingsViewModel extends GetxController {
  SettingsViewModel(this._settings, this._auth, this._cache);

  final SettingsRepository _settings;
  final AuthRepository _auth;
  final LocalCacheService _cache;

  late final languageCode = _settings.languageCode.obs;
  late final themeMode = _settings.themeMode.obs;
  late final currency = _settings.currency.obs;
  final version = ''.obs;
  final isDeleting = false.obs;

  String? get email => _auth.currentUser?.email;
  String? get displayName => _auth.currentUser?.displayName;

  @override
  void onInit() {
    super.onInit();
    PackageInfo.fromPlatform().then((i) => version.value = '${i.version} (${i.buildNumber})');
  }

  Future<void> setLanguage(String code) async {
    languageCode.value = code;
    await _settings.setLanguageCode(code);
    await Get.updateLocale(code == 'ur' ? const Locale('ur', 'PK') : const Locale('en', 'US'));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _settings.setThemeMode(mode);
    Get.changeThemeMode(mode);
  }

  Future<void> setCurrency(String code) async {
    currency.value = code;
    await _settings.setCurrency(code);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _cache.clearUserData();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> deleteAccount() async {
    if (isDeleting.value) return;
    isDeleting.value = true;
    try {
      await _auth.deleteAccount();
      await _cache.clearUserData();
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar('account_deleted'.tr, 'account_deleted_body'.tr);
    } on AppException catch (e) {
      Get.snackbar('error'.tr, e.message);
    } finally {
      isDeleting.value = false;
    }
  }
}

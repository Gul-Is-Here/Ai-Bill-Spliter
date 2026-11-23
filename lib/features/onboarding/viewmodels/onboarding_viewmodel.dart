import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../settings/repositories/settings_repository.dart';

class OnboardingViewModel extends GetxController {
  OnboardingViewModel(this._settings);

  final SettingsRepository _settings;

  static const pageCount = 3;

  final pageController = PageController();
  final page = 0.obs;

  bool get isLast => page.value == pageCount - 1;

  void onPageChanged(int index) => page.value = index;

  void next() {
    HapticFeedback.selectionClick();
    if (isLast) {
      finish();
    } else {
      pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    }
  }

  void back() => pageController.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);

  void goTo(int index) =>
      pageController.animateToPage(index, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);

  Future<void> finish() async {
    await _settings.setOnboardingDone();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

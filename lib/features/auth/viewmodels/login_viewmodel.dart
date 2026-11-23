import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/view_state.dart';
import '../repositories/auth_repository.dart';

class LoginViewModel extends GetxController {
  LoginViewModel(this._repository);

  final AuthRepository _repository;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final state = ViewState.idle.obs;
  final isRegister = false.obs;
  final showEmailForm = false.obs;

  void openEmailForm() => showEmailForm.value = true;
  final errorMessage = RxnString();

  void toggleMode() {
    isRegister.toggle();
    errorMessage.value = null;
  }

  Future<void> submitEmail() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final email = emailController.text.trim();
    final password = passwordController.text;
    await _run(() => isRegister.value
        ? _repository.registerWithEmail(nameController.text.trim(), email, password)
        : _repository.signInWithEmail(email, password));
  }

  Future<void> signInWithGoogle() => _run(_repository.signInWithGoogle);

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    if (!GetUtils.isEmail(email)) {
      errorMessage.value = 'error_invalid_email'.tr;
      return;
    }
    try {
      await _repository.sendPasswordReset(email);
      errorMessage.value = null;
      Get.snackbar('reset_sent_title'.tr, 'reset_sent_body'.tr);
    } on AppException catch (e) {
      errorMessage.value = e.message;
    }
  }

  Future<void> _run(Future<Object> Function() action) async {
    if (state.value == ViewState.loading) return;
    state.value = ViewState.loading;
    errorMessage.value = null;
    try {
      await action();
      HapticFeedback.mediumImpact();
      state.value = ViewState.success;
      Get.offAllNamed(AppRoutes.home);
    } on AppException catch (e) {
      state.value = ViewState.idle;
      if (!e.cancelled) errorMessage.value = e.message;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

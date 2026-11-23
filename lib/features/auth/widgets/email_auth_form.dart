import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/view_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../viewmodels/login_viewmodel.dart';

/// Email sign-in / register form (shown after "Continue with email").
class EmailAuthForm extends GetView<LoginViewModel> {
  const EmailAuthForm({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AutofillGroup(
      child: Form(
        key: controller.formKey,
        child: Obx(() {
          final register = controller.isRegister.value;
          final loading = controller.state.value == ViewState.loading;
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (register) ...[
              TextFormField(
                controller: controller.nameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(labelText: 'name'.tr, prefixIcon: const Icon(Icons.person_outline)),
                validator: Validators.required,
              ),
              const SizedBox(height: AppSpacing.gutter),
            ],
            TextFormField(
              controller: controller.emailController,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(labelText: 'email'.tr, prefixIcon: const Icon(Icons.mail_outline)),
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacing.gutter),
            TextFormField(
              controller: controller.passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: [register ? AutofillHints.newPassword : AutofillHints.password],
              decoration: InputDecoration(labelText: 'password'.tr, prefixIcon: const Icon(Icons.lock_outline)),
              validator: Validators.password,
              onFieldSubmitted: (_) => controller.submitEmail(),
            ),
            if (!register)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(onPressed: controller.resetPassword, child: Text('forgot_password'.tr)),
              ),
            if (controller.errorMessage.value != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Semantics(
                  liveRegion: true,
                  child: Text(controller.errorMessage.value!, style: TextStyle(color: scheme.error)),
                ),
              ),
            const SizedBox(height: AppSpacing.xs),
            PrimaryButton(
              label: register ? 'create_account'.tr : 'sign_in'.tr,
              isLoading: loading,
              onPressed: controller.submitEmail,
            ),
            TextButton(
              onPressed: loading ? null : controller.toggleMode,
              child: Text(register ? 'have_account'.tr : 'no_account'.tr),
            ),
          ]);
        }),
      ),
    );
  }
}

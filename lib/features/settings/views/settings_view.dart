import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/currency_picker.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsView extends GetView<SettingsViewModel> {
  const SettingsView({super.key});

  Future<void> _confirmDelete() async {
    final ok = await Get.dialog<bool>(AlertDialog(
      title: Text('delete_account'.tr),
      content: Text('delete_account_body'.tr),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text('cancel'.tr)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Get.theme.colorScheme.error),
          onPressed: () => Get.back(result: true),
          child: Text('delete_forever'.tr),
        ),
      ],
    ));
    if (ok ?? false) await controller.deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(controller.displayName ?? controller.email ?? ''),
          subtitle: controller.displayName == null ? null : Text(controller.email ?? ''),
        ),
        const Divider(),
        _Header('preferences'.tr),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Obx(() => SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'en', label: Text('English')),
                  ButtonSegment(value: 'ur', label: Text('اردو')),
                ],
                selected: {controller.languageCode.value},
                onSelectionChanged: (s) => controller.setLanguage(s.first),
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Obx(() => SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(value: ThemeMode.system, label: Text('theme_system'.tr)),
                  ButtonSegment(value: ThemeMode.light, label: Text('theme_light'.tr)),
                  ButtonSegment(value: ThemeMode.dark, label: Text('theme_dark'.tr)),
                ],
                selected: {controller.themeMode.value},
                onSelectionChanged: (s) => controller.setThemeMode(s.first),
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Obx(() => CurrencyPicker(value: controller.currency.value, onChanged: controller.setCurrency)),
        ),
        const Divider(),
        _Header('privacy_and_legal'.tr),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text('privacy_policy'.tr),
          onTap: () => Get.toNamed(AppRoutes.legal, arguments: 'privacy'),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text('terms'.tr),
          onTap: () => Get.toNamed(AppRoutes.legal, arguments: 'terms'),
        ),
        const Divider(),
        _Header('account'.tr),
        ListTile(leading: const Icon(Icons.logout), title: Text('sign_out'.tr), onTap: controller.signOut),
        Obx(() => ListTile(
              leading: controller.isDeleting.value
                  ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
              title: Text('delete_account'.tr, style: TextStyle(color: theme.colorScheme.error)),
              onTap: controller.isDeleting.value ? null : _confirmDelete,
            )),
        const SizedBox(height: AppSpacing.md),
        Obx(() => Text('version'.trParams({'v': controller.version.value}),
            textAlign: TextAlign.center, style: theme.textTheme.bodySmall)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      );
}

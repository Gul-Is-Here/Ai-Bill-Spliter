import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_spacing.dart';
import '../services/remote_config_service.dart';

/// Blocks the app with an update prompt when Remote Config requires a newer build.
class ForceUpdateGate extends StatelessWidget {
  const ForceUpdateGate({super.key, required this.child});

  final Widget child;

  static final _storeUri = Uri.parse('https://play.google.com/store/apps/details?id=com.aibillsplierapp.app');

  @override
  Widget build(BuildContext context) {
    final rc = Get.find<RemoteConfigService>();
    return Obx(() {
      if (!rc.updateRequired.value) return child;
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.system_update, size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: AppSpacing.lg),
                Text('update_required_title'.tr,
                    textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                Text('update_required_body'.tr, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () => launchUrl(_storeUri, mode: LaunchMode.externalApplication),
                  child: Text('update_now'.tr),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

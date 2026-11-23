import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/config/app_config.dart';
import '../../../core/constants/app_spacing.dart';

/// Privacy policy / terms, translated. Argument: 'privacy' or 'terms'.
class LegalView extends StatelessWidget {
  const LegalView({super.key});

  @override
  Widget build(BuildContext context) {
    final privacy = Get.arguments == 'privacy';
    final body = (privacy ? 'privacy_policy_body' : 'terms_body').trParams({'email': AppConfig.supportEmail});
    return Scaffold(
      appBar: AppBar(title: Text(privacy ? 'privacy_policy'.tr : 'terms'.tr)),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [Text(body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5))],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/services/permission_service.dart';
import '../models/voice_split_result.dart';
import '../repositories/voice_repository.dart';
import '../viewmodels/voice_viewmodel.dart';

class VoiceSplitSheet extends GetView<VoiceViewModel> {
  const VoiceSplitSheet({super.key});

  static Future<VoiceSplitResult?> show(List<String> itemNames) async {
    Get.put(VoiceViewModel(VoiceRepository(Get.find()), PermissionService(), Get.find(), itemNames));
    try {
      return await Get.bottomSheet<VoiceSplitResult>(
        const VoiceSplitSheet(),
        backgroundColor: Get.theme.colorScheme.surface,
      );
    } finally {
      Get.delete<VoiceViewModel>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Obx(() {
          final s = controller.status.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('voice_split'.tr, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text('voice_hint'.tr, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: switch (s) {
                  VoiceStatus.processing => const SizedBox.square(dimension: 72, child: CircularProgressIndicator()),
                  _ => IconButton.filled(
                      iconSize: 40,
                      style: IconButton.styleFrom(minimumSize: const Size(80, 80)),
                      tooltip: s == VoiceStatus.listening ? 'stop'.tr : 'try_again'.tr,
                      onPressed: s == VoiceStatus.listening ? controller.stopListening : controller.start,
                      icon: Icon(s == VoiceStatus.listening ? Icons.stop : Icons.mic),
                    ),
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                liveRegion: true,
                child: Text(
                  controller.errorMessage.value ??
                      (controller.transcript.value.isEmpty
                          ? (s == VoiceStatus.listening ? 'listening'.tr : '')
                          : controller.transcript.value),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: controller.errorMessage.value != null ? theme.colorScheme.error : null),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

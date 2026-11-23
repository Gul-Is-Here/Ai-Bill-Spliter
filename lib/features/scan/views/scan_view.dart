import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/view_state.dart';
import '../viewmodels/scan_viewmodel.dart';

class ScanView extends GetView<ScanViewModel> {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('new_bill'.tr)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Obx(() {
            final loading = controller.state.value == ViewState.loading;
            final preview = controller.previewPath.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: preview == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.document_scanner_outlined, size: 96, color: theme.colorScheme.primary),
                            const SizedBox(height: AppSpacing.md),
                            Text('scan_hint'.tr, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                          ],
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppSpacing.radius),
                              child: Image.file(File(preview), fit: BoxFit.contain, semanticLabel: 'receipt_image'.tr),
                            ),
                            if (loading)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: AppSpacing.md),
                                    Text('scanning'.tr),
                                  ]),
                                ),
                              ),
                          ],
                        ),
                ),
                if (controller.errorMessage.value != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    liveRegion: true,
                    child: Text(controller.errorMessage.value!,
                        textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: loading ? null : () => controller.scan(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: Text('take_photo'.tr),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: loading ? null : () => controller.scan(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text('choose_from_gallery'.tr),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: loading ? null : controller.enterManually,
                  child: Text('enter_manually'.tr),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

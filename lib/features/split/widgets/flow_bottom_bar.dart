import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../viewmodels/split_flow_viewmodel.dart';

/// Primary action + validation message shared by all flow screens.
class FlowBottomBar extends GetView<SplitFlowViewModel> {
  const FlowBottomBar({super.key, required this.label, required this.onPressed, this.isLoading = false});

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              final key = controller.errorKey.value;
              if (key == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Semantics(
                  liveRegion: true,
                  child: Text(key.tr,
                      textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              );
            }),
            PrimaryButton(label: label, onPressed: onPressed, isLoading: isLoading),
          ],
        ),
      ),
    );
  }
}

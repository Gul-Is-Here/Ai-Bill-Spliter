import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_spacing.dart';
import '../utils/view_state.dart';

/// Renders loading / empty / failure; delegates success and idle to [builder].
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    required this.state,
    required this.builder,
    this.emptyMessage,
    this.errorMessage,
    this.onRetry,
  });

  final ViewState state;
  final WidgetBuilder builder;
  final String? emptyMessage;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ViewState.loading => const Center(child: CircularProgressIndicator()),
      ViewState.empty => _Message(icon: Icons.inbox_outlined, text: emptyMessage ?? ''),
      ViewState.failure => _Message(
          icon: Icons.error_outline,
          text: errorMessage ?? 'error_generic'.tr,
          onRetry: onRetry,
        ),
      ViewState.idle || ViewState.success => builder(context),
    };
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: AppSpacing.md),
            Text(text, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(onPressed: onRetry, child: Text('retry'.tr)),
            ],
          ],
        ),
      ),
    );
  }
}

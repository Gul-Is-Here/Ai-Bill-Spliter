import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../widgets/onboarding_heroes.dart';

class OnboardingView extends GetView<OnboardingViewModel> {
  const OnboardingView({super.key});

  static const _heroes = [ScanHero(), SplitHero(), SettleHero()];
  static const _titles = [('onb1_title', 'onb1_accent'), ('onb2_title', 'onb2_accent'), ('onb3_title', 'onb3_accent')];
  static const _bodies = ['onb1_body', 'onb2_body', 'onb3_body'];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // Header: back · progress pill · skip
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.sm, 0),
            child: Obx(() {
              final page = controller.page.value;
              return Row(children: [
                AnimatedOpacity(
                  opacity: page == 0 ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: IconButton.filledTonal(
                    onPressed: page == 0 ? null : controller.back,
                    tooltip: 'back'.tr,
                    icon: const Icon(Icons.arrow_back, size: 20),
                  ),
                ),
                const Spacer(),
                _ProgressPill(page: page, count: OnboardingViewModel.pageCount),
                const Spacer(),
                TextButton(onPressed: controller.finish, child: Text('skip'.tr)),
              ]);
            }),
          ),
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: OnboardingViewModel.pageCount,
              itemBuilder: (context, i) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                child: Column(children: [
                  _heroes[i],
                  const SizedBox(height: AppSpacing.lg),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: '${_titles[i].$1.tr}\n'),
                      TextSpan(text: _titles[i].$2.tr, style: const TextStyle(color: AppColors.primary)),
                    ]),
                    textAlign: TextAlign.center,
                    style: text.displayLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(
                      _bodies[i].tr,
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.5),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
            child: Obx(() => Column(children: [
                  _Dots(page: controller.page.value, count: OnboardingViewModel.pageCount, onTap: controller.goTo),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: controller.isLast ? 'get_started'.tr : 'next'.tr,
                    onPressed: controller.next,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: controller.finish,
                    child: Text.rich(TextSpan(children: [
                      TextSpan(text: '${'have_account_q'.tr} ', style: TextStyle(color: scheme.onSurfaceVariant)),
                      TextSpan(
                        text: 'log_in'.tr,
                        style: const TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.w700),
                      ),
                    ])),
                  ),
                ])),
          ),
        ]),
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  const _ProgressPill({required this.page, required this.count});
  final int page;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'step_of'.trParams({'n': '${page + 1}', 'total': '$count'}),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == page ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == page
                    ? AppColors.primary
                    : (i < page ? AppColors.primary.withValues(alpha: 0.4) : scheme.surfaceContainerHighest),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          const SizedBox(width: 6),
          Text('${page + 1} / $count', style: Theme.of(context).textTheme.labelSmall),
        ]),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.page, required this.count, required this.onTap});
  final int page;
  final int count;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (var i = 0; i < count; i++)
        Semantics(
          button: true,
          selected: i == page,
          label: 'step_of'.trParams({'n': '${i + 1}', 'total': '$count'}),
          child: InkResponse(
            onTap: () => onTap(i),
            radius: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: i == page ? 28 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: i == page ? AppColors.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}

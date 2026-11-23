import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/member_avatar.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/animated_money.dart';
import '../../share/widgets/share_bill_button.dart';
import '../viewmodels/split_flow_viewmodel.dart';
import '../widgets/flow_bottom_bar.dart';

class SummaryView extends GetView<SplitFlowViewModel> {
  const SummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('summary'.tr),
        actions: [Obx(() => ShareBillButton(bill: controller.bill.value))],
      ),
      body: Obx(() {
        final b = controller.bill.value;
        final payer = b.participants.where((p) => p.id == b.payerId).firstOrNull;
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(children: [
                  Text(b.title.isEmpty ? 'untitled_bill'.tr : b.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  AnimatedMoney(minor: b.totalMinor, currency: b.currency, style: theme.textTheme.displaySmall),
                  if (payer != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text('paid_by'.trParams({'name': payer.name})),
                  ],
                ]),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final p in b.participants)
              ListTile(
                leading: MemberAvatar(id: p.id, name: p.name),
                title: Text(p.name),
                subtitle: p.id == b.payerId ? Text('paid_the_bill'.tr) : Text('owes_payer'.tr),
                trailing: Text(Money.format(b.shares[p.id] ?? 0, b.currency), style: theme.textTheme.titleMedium),
              ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() => FlowBottomBar(
            label: 'save_bill'.tr,
            isLoading: controller.isSaving.value,
            onPressed: controller.save,
          )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/money.dart';
import '../../bill/models/bill.dart';
import '../services/split_calculator.dart';
import '../viewmodels/split_flow_viewmodel.dart';
import '../widgets/flow_bottom_bar.dart';

/// Item-wise: tap people per item. Percentage: one slider per person.
class AssignItemsView extends GetView<SplitFlowViewModel> {
  const AssignItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    final itemwise = controller.bill.value.splitMethod == SplitMethod.itemwise;
    return Scaffold(
      appBar: AppBar(
        title: Text(itemwise ? 'assign_items'.tr : 'set_percentages'.tr),
        actions: [
          if (!itemwise) TextButton(onPressed: controller.evenPercentages, child: Text('split_evenly'.tr)),
        ],
      ),
      body: itemwise ? const _ItemwiseList() : const _PercentageList(),
      bottomNavigationBar: FlowBottomBar(label: 'see_summary'.tr, onPressed: controller.continueFromAssign),
    );
  }
}

class _ItemwiseList extends GetView<SplitFlowViewModel> {
  const _ItemwiseList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final b = controller.bill.value;
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: b.items.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, index) {
          final item = b.items[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(item.name, style: Theme.of(context).textTheme.titleSmall)),
                Text(Money.format(item.totalMinor, b.currency)),
              ]),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final p in b.participants)
                    FilterChip(
                      label: Text(p.name),
                      selected: item.assignedTo.contains(p.id),
                      onSelected: (_) => controller.toggleAssignment(item.id, p.id),
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.groups_outlined, size: 18),
                    label: Text('everyone'.tr),
                    onPressed: () => controller.assignToEveryone(item.id),
                  ),
                ],
              ),
            ],
          );
        },
      );
    });
  }
}

class _PercentageList extends GetView<SplitFlowViewModel> {
  const _PercentageList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final b = controller.bill.value;
      final total = controller.percentTotal;
      final ok = total == SplitCalculator.fullPercent;
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          for (final p in b.participants) ...[
            Row(children: [
              Expanded(child: Text(p.name)),
              Text('${((b.percentages[p.id] ?? 0) / 100).toStringAsFixed(1)}%'),
            ]),
            Slider(
              value: (b.percentages[p.id] ?? 0).toDouble(),
              max: SplitCalculator.fullPercent.toDouble(),
              divisions: 200,
              label: '${((b.percentages[p.id] ?? 0) / 100).toStringAsFixed(1)}%',
              semanticFormatterCallback: (v) => '${p.name} ${(v / 100).toStringAsFixed(1)}%',
              onChanged: (v) => controller.setPercentage(p.id, v.round()),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            'percent_total'.trParams({'value': (total / 100).toStringAsFixed(1)}),
            textAlign: TextAlign.center,
            style: TextStyle(color: ok ? null : Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
          ),
        ],
      );
    });
  }
}

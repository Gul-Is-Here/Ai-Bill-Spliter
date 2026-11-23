import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/money.dart';
import '../../history/widgets/bill_tile.dart';
import '../models/settlement.dart';
import '../viewmodels/group_detail_viewmodel.dart';

class GroupDetailView extends GetView<GroupDetailViewModel> {
  const GroupDetailView({super.key});

  Future<void> _addBill() async {
    await Get.toNamed(AppRoutes.scan, parameters: {'groupId': controller.group.value.id});
    await controller.load();
  }

  Future<void> _addMember() async {
    final text = TextEditingController();
    final name = await Get.dialog<String>(AlertDialog(
      title: Text('add_person'.tr),
      content: TextField(
        controller: text,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (v) => Get.back(result: v),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
        FilledButton(onPressed: () => Get.back(result: text.text), child: Text('save'.tr)),
      ],
    ));
    text.dispose();
    if (name != null) await controller.addMember(name);
  }

  Future<void> _confirmPayment(Settlement s) async {
    final ok = await Get.dialog<bool>(AlertDialog(
      title: Text('record_payment'.tr),
      content: Text('record_payment_body'.trParams({
        'from': controller.nameOf(s.fromId),
        'to': controller.nameOf(s.toId),
        'amount': Money.format(s.amountMinor, s.currency),
      })),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text('cancel'.tr)),
        FilledButton(onPressed: () => Get.back(result: true), child: Text('mark_paid'.tr)),
      ],
    ));
    if (ok ?? false) await controller.recordPayment(s);
  }

  Future<void> _confirmDelete() async {
    final ok = await Get.dialog<bool>(AlertDialog(
      title: Text('delete_group'.tr),
      content: Text('delete_group_body'.tr),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text('cancel'.tr)),
        FilledButton(onPressed: () => Get.back(result: true), child: Text('delete'.tr)),
      ],
    ));
    if (ok ?? false) await controller.deleteGroup();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.group.value.name)),
        actions: [
          IconButton(icon: const Icon(Icons.person_add_alt_1), tooltip: 'add_person'.tr, onPressed: _addMember),
          IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'delete_group'.tr, onPressed: _confirmDelete),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addBill,
        icon: const Icon(Icons.add),
        label: Text('add_bill'.tr),
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(() {
          final g = controller.group.value;
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              _Section('balances'.tr),
              for (final m in g.members)
                for (final entry in controller.balances.entries)
                  if ((entry.value[m.id] ?? 0) != 0)
                    ListTile(
                      title: Text(m.name),
                      trailing: Text(
                        (entry.value[m.id]! > 0 ? 'gets_back' : 'owes').trParams({
                          'amount': Money.format(entry.value[m.id]!.abs(), entry.key),
                        }),
                        style: TextStyle(
                          color: entry.value[m.id]! > 0 ? Colors.green.shade700 : theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
              if (controller.suggested.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text('all_settled'.tr, textAlign: TextAlign.center),
                )
              else ...[
                _Section('settle_up'.tr),
                for (final s in controller.suggested)
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: Text('pays'.trParams({'from': controller.nameOf(s.fromId), 'to': controller.nameOf(s.toId)})),
                    subtitle: Text(Money.format(s.amountMinor, s.currency)),
                    trailing: OutlinedButton(onPressed: () => _confirmPayment(s), child: Text('mark_paid'.tr)),
                  ),
              ],
              _Section('bills'.tr),
              if (controller.bills.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text('group_no_bills'.tr, textAlign: TextAlign.center),
                ),
              for (final b in controller.bills)
                BillTile(bill: b, onTap: () => Get.toNamed(AppRoutes.billDetail, arguments: b)),
            ],
          );
        }),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      );
}

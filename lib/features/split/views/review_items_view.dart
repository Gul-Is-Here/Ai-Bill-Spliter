import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/animated_money.dart';
import '../../../core/widgets/money_field.dart';
import '../viewmodels/split_flow_viewmodel.dart';
import '../widgets/flow_bottom_bar.dart';
import '../widgets/item_editor_sheet.dart';
import '../widgets/receipt_thumbnail.dart';

class ReviewItemsView extends StatefulWidget {
  const ReviewItemsView({super.key});

  @override
  State<ReviewItemsView> createState() => _ReviewItemsViewState();
}

/// Stateful only to own the text controllers; all state lives in the ViewModel.
class _ReviewItemsViewState extends State<ReviewItemsView> {
  final vm = Get.find<SplitFlowViewModel>();
  late final _title = TextEditingController(text: vm.bill.value.title);
  late final _tax = _ctrl(vm.bill.value.taxMinor);
  late final _tip = _ctrl(vm.bill.value.tipMinor);
  late final _service = _ctrl(vm.bill.value.serviceChargeMinor);
  late final _discount = _ctrl(vm.bill.value.discountMinor);

  TextEditingController _ctrl(int minor) =>
      TextEditingController(text: minor == 0 ? '' : Money.toInput(minor, vm.bill.value.currency));

  @override
  void dispose() {
    for (final c in [_title, _tax, _tip, _service, _discount]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addItem() async {
    final r = await ItemEditorSheet.show(vm.bill.value.currency);
    if (r != null) vm.addItem(r.name, r.totalMinor, r.quantity);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = vm.bill.value.currency;
    return Scaffold(
      appBar: AppBar(title: Text('review_items'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Row(children: [
            ReceiptThumbnail(bill: vm.bill.value, size: 64),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextField(
                controller: _title,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: 'bill_title'.tr),
                onChanged: vm.setTitle,
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [
            Expanded(child: Text('items'.tr, style: theme.textTheme.titleMedium)),
            TextButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: Text('add_item'.tr)),
          ]),
          Obx(() {
            final items = vm.bill.value.items;
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text('no_items_yet'.tr, textAlign: TextAlign.center),
              );
            }
            return Column(children: [
              for (final item in items)
                Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    color: theme.colorScheme.errorContainer,
                    child: Icon(Icons.delete_outline, semanticLabel: 'delete'.tr),
                  ),
                  onDismissed: (_) => vm.removeItem(item.id),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.name),
                    subtitle: item.quantity == 1 ? null : Text('× ${item.quantity}'),
                    trailing: Text(Money.format(item.totalMinor, currency)),
                    onTap: () async {
                      final r = await ItemEditorSheet.show(currency, item: item);
                      if (r != null) {
                        vm.updateItem(item.id, name: r.name, totalMinor: r.totalMinor, quantity: r.quantity);
                      }
                    },
                  ),
                ),
            ]);
          }),
          const Divider(height: AppSpacing.xl),
          Text('extras'.tr, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            Expanded(child: MoneyField(controller: _tax, label: 'tax'.tr, currency: currency, onChanged: (v) => vm.setExtras(tax: v))),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: MoneyField(controller: _tip, label: 'tip'.tr, currency: currency, onChanged: (v) => vm.setExtras(tip: v))),
          ]),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(
                child: MoneyField(
                    controller: _service,
                    label: 'service_charge'.tr,
                    currency: currency,
                    onChanged: (v) => vm.setExtras(serviceCharge: v))),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: MoneyField(
                    controller: _discount,
                    label: 'discount'.tr,
                    currency: currency,
                    textInputAction: TextInputAction.done,
                    onChanged: (v) => vm.setExtras(discount: v))),
          ]),
          const SizedBox(height: AppSpacing.lg),
          Obx(() => Row(children: [
                Expanded(child: Text('total'.tr, style: theme.textTheme.titleLarge)),
                AnimatedMoney(minor: vm.bill.value.totalMinor, currency: currency, style: theme.textTheme.titleLarge),
              ])),
        ],
      ),
      bottomNavigationBar: FlowBottomBar(label: 'next'.tr, onPressed: vm.continueFromReview),
    );
  }
}

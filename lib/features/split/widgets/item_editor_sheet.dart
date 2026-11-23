import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/money_field.dart';
import '../../bill/models/bill_item.dart';

class ItemEditResult {
  const ItemEditResult(this.name, this.totalMinor, this.quantity);
  final String name;
  final int totalMinor;
  final double quantity;
}

/// Bottom sheet for adding or editing a line item.
class ItemEditorSheet extends StatefulWidget {
  const ItemEditorSheet({super.key, required this.currency, this.item});

  final String currency;
  final BillItem? item;

  static Future<ItemEditResult?> show(String currency, {BillItem? item}) => Get.bottomSheet<ItemEditResult>(
        ItemEditorSheet(currency: currency, item: item),
        isScrollControlled: true,
        backgroundColor: Get.theme.colorScheme.surface,
      );

  @override
  State<ItemEditorSheet> createState() => _ItemEditorSheetState();
}

class _ItemEditorSheetState extends State<ItemEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.item?.name);
  late final _qty = TextEditingController(text: _formatQty(widget.item?.quantity ?? 1));
  late final _total = TextEditingController(
      text: widget.item == null ? '' : Money.toInput(widget.item!.totalMinor, widget.currency));

  static String _formatQty(double q) => q == q.roundToDouble() ? q.toInt().toString() : q.toString();

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    _total.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Get.back(
      result: ItemEditResult(
        _name.text,
        Money.parse(_total.text, widget.currency)!,
        double.parse(_qty.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.item == null ? 'add_item'.tr : 'edit_item'.tr,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _name,
                  autofocus: widget.item == null,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: 'item_name'.tr),
                  validator: Validators.required,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(children: [
                  SizedBox(
                    width: 96,
                    child: TextFormField(
                      controller: _qty,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: 'quantity'.tr),
                      validator: (v) {
                        final q = double.tryParse(v ?? '');
                        return q == null || q <= 0 ? 'error_invalid_amount'.tr : null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: MoneyField(
                      controller: _total,
                      label: 'line_total'.tr,
                      currency: widget.currency,
                      allowEmpty: false,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ]),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(onPressed: _submit, child: Text('save'.tr)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

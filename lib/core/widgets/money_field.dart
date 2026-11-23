import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../utils/money.dart';

/// Numeric input that reports minor units. Empty counts as 0 when [allowEmpty].
class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.controller,
    required this.label,
    required this.currency,
    this.onChanged,
    this.allowEmpty = true,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final String currency;
  final ValueChanged<int>? onChanged;
  final bool allowEmpty;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: textInputAction,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(labelText: label, suffixText: currency),
      validator: (v) {
        if ((v ?? '').trim().isEmpty) return allowEmpty ? null : 'error_required'.tr;
        return Money.parse(v!, currency) == null ? 'error_invalid_amount'.tr : null;
      },
      onChanged: (v) {
        final parsed = v.trim().isEmpty ? 0 : Money.parse(v, currency);
        if (parsed != null) onChanged?.call(parsed);
      },
    );
  }
}

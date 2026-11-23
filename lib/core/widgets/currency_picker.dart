import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Common currencies; PKR first as the default market.
class CurrencyPicker extends StatelessWidget {
  const CurrencyPicker({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const currencies = ['PKR', 'USD', 'EUR', 'GBP', 'AED', 'SAR', 'INR', 'CAD', 'AUD', 'TRY', 'MYR', 'QAR'];

  @override
  Widget build(BuildContext context) {
    final options = currencies.contains(value) ? currencies : [value, ...currencies];
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: 'currency'.tr),
      items: [for (final c in options) DropdownMenuItem(value: c, child: Text(c))],
      onChanged: (c) {
        if (c != null) onChanged(c);
      },
    );
  }
}

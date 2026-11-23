import '../../../core/errors/app_exception.dart';
import '../../bill/models/bill.dart';
import '../../bill/models/bill_item.dart';

/// Second line of defence after the server schema check: never trust shapes coming over the wire.
abstract class ReceiptParser {
  static Bill toBill(
    Map<String, dynamic> json, {
    required String id,
    required String fallbackCurrency,
    required String receiptPath,
    required DateTime now,
  }) {
    final rawItems = json['items'];
    if (rawItems is! List || rawItems.isEmpty) throw const AppException('error_invalid_response');

    final items = <BillItem>[];
    for (var i = 0; i < rawItems.length; i++) {
      final it = rawItems[i];
      if (it is! Map) throw const AppException('error_invalid_response');
      final name = it['name'];
      final total = it['totalMinor'];
      final qty = it['quantity'];
      if (name is! String || name.trim().isEmpty || total is! num || total < 0) {
        throw const AppException('error_invalid_response');
      }
      items.add(BillItem(
        id: 'i$i',
        name: name.trim(),
        totalMinor: total.toInt(),
        quantity: qty is num && qty > 0 ? qty.toDouble() : 1,
      ));
    }

    int money(String key) {
      final v = json[key];
      return v is num && v >= 0 ? v.toInt() : 0;
    }

    final currency = json['currency'];
    final date = json['date'] is String ? DateTime.tryParse(json['date'] as String) : null;
    final merchant = json['merchant'];
    return Bill(
      id: id,
      title: merchant is String ? merchant : '',
      currency: currency is String && RegExp(r'^[A-Z]{3}$').hasMatch(currency) ? currency : fallbackCurrency,
      date: date ?? now,
      items: items,
      taxMinor: money('taxMinor'),
      tipMinor: money('tipMinor'),
      serviceChargeMinor: money('serviceChargeMinor'),
      discountMinor: money('discountMinor'),
      receiptPath: receiptPath,
    );
  }
}

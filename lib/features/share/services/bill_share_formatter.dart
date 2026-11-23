import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/money.dart';
import '../../bill/models/bill.dart';

/// Builds the plain-text message shared to WhatsApp/SMS etc.
abstract class BillShareFormatter {
  static String format(Bill bill) {
    final payer = bill.participants.where((p) => p.id == bill.payerId).firstOrNull;
    final title = bill.title.isEmpty ? 'untitled_bill'.tr : bill.title;
    final lines = <String>[
      '🧾 $title — ${DateFormat.yMMMd(Get.locale?.toLanguageTag()).format(bill.date)}',
      '${'total'.tr}: ${Money.format(bill.totalMinor, bill.currency)}',
      if (payer != null) 'paid_by'.trParams({'name': payer.name}),
      '',
      for (final p in bill.participants)
        if (p.id != bill.payerId)
          '• ${p.name}: ${Money.format(bill.shares[p.id] ?? 0, bill.currency)}'
        else
          '• ${p.name}: ${Money.format(bill.shares[p.id] ?? 0, bill.currency)} (${'paid_the_bill'.tr})',
      '',
      'shared_via'.tr,
    ];
    return lines.join('\n');
  }
}

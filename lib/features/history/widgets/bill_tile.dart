import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/money.dart';
import '../../bill/models/bill.dart';
import '../../split/widgets/receipt_thumbnail.dart';

class BillTile extends StatelessWidget {
  const BillTile({super.key, required this.bill, required this.onTap});

  final Bill bill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd(Get.locale?.toLanguageTag()).format(bill.date);
    return ListTile(
      onTap: onTap,
      leading: ReceiptThumbnail(bill: bill, size: 48),
      title: Text(bill.title.isEmpty ? 'untitled_bill'.tr : bill.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('$date · ${'people_count'.trParams({'count': '${bill.participants.length}'})}'),
      trailing: Text(Money.format(bill.totalMinor, bill.currency), style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

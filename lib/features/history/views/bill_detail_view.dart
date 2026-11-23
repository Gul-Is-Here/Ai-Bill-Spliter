import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/money.dart';
import '../../bill/models/bill.dart';
import '../../share/widgets/share_bill_button.dart';
import '../../split/widgets/receipt_thumbnail.dart';
import '../viewmodels/history_viewmodel.dart';

class BillDetailView extends StatelessWidget {
  const BillDetailView({super.key});

  Future<void> _confirmDelete(Bill bill) async {
    final ok = await Get.dialog<bool>(AlertDialog(
      title: Text('delete_bill'.tr),
      content: Text('delete_bill_body'.tr),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text('cancel'.tr)),
        FilledButton(onPressed: () => Get.back(result: true), child: Text('delete'.tr)),
      ],
    ));
    if (ok ?? false) {
      await Get.find<HistoryViewModel>().delete(bill);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bill = Get.arguments as Bill;
    final theme = Theme.of(context);
    final payer = bill.participants.where((p) => p.id == bill.payerId).firstOrNull;
    final hasImage = bill.localImagePath != null || bill.receiptPath != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(bill.title.isEmpty ? 'untitled_bill'.tr : bill.title),
        actions: [
          ShareBillButton(bill: bill),
          IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'delete'.tr, onPressed: () => _confirmDelete(bill)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (hasImage)
            GestureDetector(
              onTap: () => Get.to(() => _FullImage(bill: bill), fullscreenDialog: true),
              child: Center(child: ReceiptThumbnail(bill: bill, size: 180, fit: BoxFit.contain)),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(DateFormat.yMMMMd(Get.locale?.toLanguageTag()).format(bill.date), textAlign: TextAlign.center),
          Text(Money.format(bill.totalMinor, bill.currency),
              textAlign: TextAlign.center, style: theme.textTheme.displaySmall),
          if (payer != null) Text('paid_by'.trParams({'name': payer.name}), textAlign: TextAlign.center),
          const Divider(height: AppSpacing.xl),
          for (final p in bill.participants)
            ListTile(
              title: Text(p.name),
              trailing: Text(Money.format(bill.shares[p.id] ?? 0, bill.currency)),
            ),
          const Divider(height: AppSpacing.xl),
          Text('items'.tr, style: theme.textTheme.titleMedium),
          for (final item in bill.items)
            ListTile(
              dense: true,
              title: Text(item.name),
              trailing: Text(Money.format(item.totalMinor, bill.currency)),
            ),
        ],
      ),
    );
  }
}

class _FullImage extends StatelessWidget {
  const _FullImage({required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: InteractiveViewer(
        maxScale: 5,
        child: Center(
          child: LayoutBuilder(
            builder: (context, c) => ReceiptThumbnail(bill: bill, size: c.biggest.shortestSide, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

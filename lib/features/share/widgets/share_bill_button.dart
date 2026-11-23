import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/analytics_service.dart';
import '../../bill/models/bill.dart';
import '../services/bill_share_formatter.dart';

class ShareBillButton extends StatelessWidget {
  const ShareBillButton({super.key, required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share_outlined),
      tooltip: 'share'.tr,
      onPressed: () async {
        HapticFeedback.lightImpact();
        final result = await SharePlus.instance.share(ShareParams(text: BillShareFormatter.format(bill)));
        if (result.status != ShareResultStatus.dismissed) {
          Get.find<AnalyticsService>().log(AnalyticsEvent.billShared, {'method': bill.splitMethod.name});
        }
      },
    );
  }
}

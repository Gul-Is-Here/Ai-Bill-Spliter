import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/state_view.dart';
import '../viewmodels/history_viewmodel.dart';
import '../widgets/bill_tile.dart';

class HistoryView extends GetView<HistoryViewModel> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => StateView(
          state: controller.state.value,
          emptyMessage: 'history_empty'.tr,
          errorMessage: controller.errorMessage.value,
          onRetry: controller.refreshBills,
          builder: (context) => RefreshIndicator(
            onRefresh: controller.refreshBills,
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.extentAfter < 400) controller.loadMore();
                return false;
              },
              child: Obx(() => ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: controller.bills.length + (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == controller.bills.length) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final bill = controller.bills[i];
                      return BillTile(
                        bill: bill,
                        onTap: () => Get.toNamed(AppRoutes.billDetail, arguments: bill),
                      );
                    },
                  )),
            ),
          ),
        ));
  }
}

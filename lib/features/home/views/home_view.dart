import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../groups/views/groups_view.dart';
import '../../groups/widgets/create_group_sheet.dart';
import '../../history/viewmodels/history_viewmodel.dart';
import '../../history/views/history_view.dart';
import '../../settings/views/settings_view.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeView extends GetView<HomeViewModel> {
  const HomeView({super.key});

  Future<void> _newBill() async {
    await Get.toNamed(AppRoutes.scan);
    Get.find<HistoryViewModel>().reloadLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tab = controller.tab.value;
      return Scaffold(
        appBar: AppBar(title: Text(const ['app_name', 'groups', 'settings'][tab].tr)),
        body: IndexedStack(
          index: tab,
          children: const [HistoryView(), GroupsView(), SettingsView()],
        ),
        floatingActionButton: switch (tab) {
          0 => FloatingActionButton.extended(
              onPressed: _newBill,
              icon: const Icon(Icons.document_scanner),
              label: Text('new_bill'.tr),
            ),
          1 => FloatingActionButton.extended(
              onPressed: CreateGroupSheet.show,
              icon: const Icon(Icons.group_add),
              label: Text('new_group'.tr),
            ),
          _ => null,
        },
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: controller.selectTab,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.receipt_long_outlined),
                  selectedIcon: const Icon(Icons.receipt_long),
                  label: 'bills'.tr,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.groups_outlined),
                  selectedIcon: const Icon(Icons.groups),
                  label: 'groups'.tr,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: 'settings'.tr,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

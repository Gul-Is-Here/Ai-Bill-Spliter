import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/state_view.dart';
import '../models/group.dart';
import '../viewmodels/groups_viewmodel.dart';

class GroupsView extends GetView<GroupsViewModel> {
  const GroupsView({super.key});

  static const icons = {
    GroupType.trip: Icons.flight_takeoff,
    GroupType.home: Icons.home_outlined,
    GroupType.friends: Icons.groups_outlined,
    GroupType.other: Icons.folder_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() => StateView(
          state: controller.state.value,
          emptyMessage: 'groups_empty'.tr,
          errorMessage: controller.errorMessage.value,
          onRetry: controller.refreshGroups,
          builder: (context) => RefreshIndicator(
            onRefresh: controller.refreshGroups,
            child: Obx(() => ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: controller.groups.length,
                  itemBuilder: (context, i) {
                    final g = controller.groups[i];
                    return ListTile(
                      leading: CircleAvatar(child: Icon(icons[g.type])),
                      title: Text(g.name),
                      subtitle: Text('${'people_count'.trParams({'count': '${g.members.length}'})} · ${g.currency}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Get.toNamed(AppRoutes.groupDetail, arguments: g),
                    );
                  },
                )),
          ),
        ));
  }
}

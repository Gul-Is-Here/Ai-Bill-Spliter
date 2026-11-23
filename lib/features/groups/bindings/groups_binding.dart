import 'package:get/get.dart';

import '../models/group.dart';
import '../viewmodels/group_detail_viewmodel.dart';
import '../viewmodels/groups_viewmodel.dart';

class GroupsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => GroupsViewModel(Get.find()), fenix: true);
}

class GroupDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GroupDetailViewModel(Get.find(), Get.find(), Get.find(), Get.arguments as Group));
  }
}

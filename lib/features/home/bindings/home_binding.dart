import 'package:get/get.dart';

import '../../groups/bindings/groups_binding.dart';
import '../../history/bindings/history_binding.dart';
import '../../settings/bindings/settings_binding.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(HomeViewModel.new);
    HistoryBinding().dependencies();
    GroupsBinding().dependencies();
    SettingsBinding().dependencies();
  }
}

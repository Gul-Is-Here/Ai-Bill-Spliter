import 'package:get/get.dart';

import '../viewmodels/settings_viewmodel.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => SettingsViewModel(Get.find(), Get.find(), Get.find()), fenix: true);
}

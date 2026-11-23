import 'package:get/get.dart';

import '../viewmodels/history_viewmodel.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => HistoryViewModel(Get.find(), Get.find()), fenix: true);
}

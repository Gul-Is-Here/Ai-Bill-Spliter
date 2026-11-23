import 'package:get/get.dart';

import '../viewmodels/split_flow_viewmodel.dart';

/// Bound on the first flow screen; later flow screens reuse the same ViewModel.
class SplitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplitFlowViewModel(Get.find(), Get.find()));
  }
}

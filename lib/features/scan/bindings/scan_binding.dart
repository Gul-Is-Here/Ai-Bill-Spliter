import 'package:get/get.dart';

import '../../../core/services/permission_service.dart';
import '../repositories/scan_repository.dart';
import '../viewmodels/scan_viewmodel.dart';

class ScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ScanViewModel(
          ScanRepository(Get.find()),
          PermissionService(),
          Get.find(),
          Get.find(),
          Get.find(),
          Get.find(),
        ));
  }
}

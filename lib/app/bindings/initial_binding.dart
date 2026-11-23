import 'package:get/get.dart';

import '../../core/services/functions_client.dart';
import '../../core/services/local_cache_service.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/bill/repositories/bill_repository.dart';
import '../../features/groups/repositories/group_repository.dart';
import '../../features/settings/repositories/settings_repository.dart';

/// App-wide singletons shared by several features.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FunctionsClient(), permanent: true);
    Get.put(AuthRepository(Get.find()), permanent: true);
    final local = Get.find<LocalCacheService>();
    final cache = local.cache;
    Get.put(SettingsRepository(local.settings), permanent: true);
    Get.put(BillRepository(cache), permanent: true);
    Get.put(GroupRepository(cache), permanent: true);
  }
}

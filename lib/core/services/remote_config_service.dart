import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Force-update check: Remote Config key `min_build_number` vs the installed build.
class RemoteConfigService extends GetxService {
  final updateRequired = false.obs;

  @override
  void onReady() {
    super.onReady();
    _check();
  }

  Future<void> _check() async {
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await rc.setDefaults(const {'min_build_number': 0});
      await rc.fetchAndActivate();
      final info = await PackageInfo.fromPlatform();
      final installed = int.tryParse(info.buildNumber) ?? 0;
      updateRequired.value = installed < rc.getInt('min_build_number');
    } catch (_) {
      // Offline or fetch failure: never block the user on a failed check.
    }
  }
}

import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../core/services/analytics_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/local_cache_service.dart';
import '../core/services/remote_config_service.dart';
import 'app.dart';
import 'config/app_config.dart';

/// Shared entry point for every flavor. Only work needed for the first frame is awaited.
Future<void> bootstrap(Flavor flavor) async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppConfig.init(flavor);

    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      providerAndroid: flavor == Flavor.prod
          ? const AndroidPlayIntegrityProvider()
          : const AndroidDebugProvider(),
      providerApple: flavor == Flavor.prod
          ? const AppleAppAttestProvider()
          : const AppleDebugProvider(),
    );

    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = crashlytics.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    await Hive.initFlutter();
    final cache = await LocalCacheService().init();
    Get.put(cache, permanent: true);
    Get.put(ConnectivityService(), permanent: true);
    Get.put(AnalyticsService(), permanent: true);
    // Non-critical: fetched after first frame, force-update screen reacts when ready.
    Get.put(RemoteConfigService(), permanent: true);

    runApp(const MyApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

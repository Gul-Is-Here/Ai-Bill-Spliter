import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../core/services/local_cache_service.dart';
import '../features/settings/repositories/settings_repository.dart';
import 'bindings/initial_binding.dart';
import '../core/widgets/force_update_gate.dart';
import '../core/widgets/offline_banner.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'translations/app_translations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const supportedLocales = [Locale('en', 'US'), Locale('ur', 'PK')];

  @override
  Widget build(BuildContext context) {
    final settings = SettingsRepository(Get.find<LocalCacheService>().settings);
    final code = settings.languageCode;
    return GetMaterialApp(
      onGenerateTitle: (_) => 'app_name'.tr,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      translations: AppTranslations(),
      locale: supportedLocales.firstWhere((l) => l.languageCode == code),
      fallbackLocale: supportedLocales.first,
      supportedLocales: supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      initialBinding: InitialBinding(),
      initialRoute: FirebaseAuth.instance.currentUser != null
          ? AppRoutes.home
          : (settings.onboardingDone ? AppRoutes.login : AppRoutes.onboarding),
      getPages: AppPages.pages,
      builder: (context, child) => ForceUpdateGate(child: OfflineBanner(child: child!)),
    );
  }
}

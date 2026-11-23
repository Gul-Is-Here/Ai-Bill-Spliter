import 'package:ai_bill_spliter/app/theme/app_colors.dart';
import 'package:ai_bill_spliter/app/translations/app_translations.dart';
import 'package:ai_bill_spliter/features/auth/repositories/auth_repository.dart';
import 'package:ai_bill_spliter/features/auth/viewmodels/login_viewmodel.dart';
import 'package:ai_bill_spliter/features/auth/views/login_view.dart';
import 'package:ai_bill_spliter/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:ai_bill_spliter/features/onboarding/views/onboarding_view.dart';
import 'package:ai_bill_spliter/features/settings/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeSettings extends Fake implements SettingsRepository {
  bool done = false;

  @override
  Future<void> setOnboardingDone() async => done = true;
}

class FakeAuth extends Fake implements AuthRepository {}

// Plain theme in tests: google_fonts can't download fonts here.
final _theme = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brand));

Future<void> pumpApp(WidgetTester tester, Widget home, Locale locale) async {
  Get.testMode = true;
  tester.view.physicalSize = const Size(360, 690) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(GetMaterialApp(
    theme: _theme,
    translations: AppTranslations(),
    locale: locale,
    supportedLocales: const [Locale('en', 'US'), Locale('ur', 'PK')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    getPages: [
      GetPage(name: '/', page: () => home),
      GetPage(name: '/login', page: () => const Scaffold(body: Text('login-page'))),
    ],
  ));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);

  for (final locale in const [Locale('en', 'US'), Locale('ur', 'PK')]) {
    testWidgets('onboarding: all 3 pages render without overflow (${locale.languageCode})', (tester) async {
      final settings = FakeSettings();
      final vm = Get.put(OnboardingViewModel(settings));
      await pumpApp(tester, const OnboardingView(), locale);

      for (var i = 0; i < OnboardingViewModel.pageCount; i++) {
        expect(tester.takeException(), isNull);
        expect(vm.page.value, i);
        if (i < OnboardingViewModel.pageCount - 1) {
          vm.next();
          await tester.pumpAndSettle();
        }
      }
      expect(vm.isLast, isTrue);
      vm.next(); // Get started
      await tester.pumpAndSettle();
      expect(settings.done, isTrue);
      expect(find.text('login-page'), findsOneWidget);
    });

    testWidgets('login: renders and opens the email form (${locale.languageCode})', (tester) async {
      Get.put(LoginViewModel(FakeAuth()));
      await pumpApp(tester, const LoginView(), locale);
      expect(tester.takeException(), isNull);
      expect(find.byType(TextFormField), findsNothing);

      await tester.ensureVisible(find.text('continue_with_email'.tr));
      await tester.pumpAndSettle();
      await tester.tap(find.text('continue_with_email'.tr));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  }

  testWidgets('onboarding: Skip finishes immediately', (tester) async {
    final settings = FakeSettings();
    Get.put(OnboardingViewModel(settings));
    await pumpApp(tester, const OnboardingView(), const Locale('en', 'US'));
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(settings.done, isTrue);
  });
}

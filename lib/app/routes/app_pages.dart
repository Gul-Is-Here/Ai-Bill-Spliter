import 'package:get/get.dart';

import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/groups/bindings/groups_binding.dart';
import '../../features/groups/views/group_detail_view.dart';
import '../../features/history/views/bill_detail_view.dart';
import '../../features/onboarding/bindings/onboarding_binding.dart';
import '../../features/onboarding/views/onboarding_view.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_view.dart';
import '../../features/scan/bindings/scan_binding.dart';
import '../../features/settings/views/legal_view.dart';
import '../../features/scan/views/scan_view.dart';
import '../../features/split/bindings/split_binding.dart';
import '../../features/split/views/assign_items_view.dart';
import '../../features/split/views/participants_view.dart';
import '../../features/split/views/review_items_view.dart';
import '../../features/split/views/summary_view.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView(), binding: OnboardingBinding()),
    GetPage(name: AppRoutes.login, page: () => const LoginView(), binding: AuthBinding()),
    GetPage(name: AppRoutes.home, page: () => const HomeView(), binding: HomeBinding()),
    GetPage(name: AppRoutes.scan, page: () => const ScanView(), binding: ScanBinding()),
    // Flow screens share SplitFlowViewModel, created by the first one.
    GetPage(name: AppRoutes.reviewItems, page: () => const ReviewItemsView(), binding: SplitBinding()),
    GetPage(name: AppRoutes.participants, page: () => const ParticipantsView()),
    GetPage(name: AppRoutes.assign, page: () => const AssignItemsView()),
    GetPage(name: AppRoutes.summary, page: () => const SummaryView()),
    GetPage(name: AppRoutes.billDetail, page: () => const BillDetailView()),
    GetPage(name: AppRoutes.legal, page: () => const LegalView()),
    GetPage(name: AppRoutes.groupDetail, page: () => const GroupDetailView(), binding: GroupDetailBinding()),
  ];
}

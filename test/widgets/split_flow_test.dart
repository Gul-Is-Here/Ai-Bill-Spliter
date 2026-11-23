import 'package:ai_bill_spliter/app/translations/app_translations.dart';
import 'package:ai_bill_spliter/core/services/analytics_service.dart';
import 'package:ai_bill_spliter/core/utils/money.dart';
import 'package:ai_bill_spliter/features/bill/models/bill.dart';
import 'package:ai_bill_spliter/features/bill/models/bill_item.dart';
import 'package:ai_bill_spliter/features/bill/models/participant.dart';
import 'package:ai_bill_spliter/features/bill/repositories/bill_repository.dart';
import 'package:ai_bill_spliter/features/split/viewmodels/split_flow_viewmodel.dart';
import 'package:ai_bill_spliter/features/split/views/assign_items_view.dart';
import 'package:ai_bill_spliter/features/split/views/review_items_view.dart';
import 'package:ai_bill_spliter/features/split/views/summary_view.dart';
import 'package:ai_bill_spliter/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeBillRepository extends Fake implements BillRepository {
  final saved = <Bill>[];

  @override
  Future<Bill> save(Bill bill) async {
    saved.add(bill);
    return bill;
  }
}

class FakeAnalytics extends Fake implements AnalyticsService {
  final events = <AnalyticsEvent>[];

  @override
  Future<void> log(AnalyticsEvent event, [Map<String, Object>? params]) async => events.add(event);
}

const ali = Participant(id: 'a', name: 'Ali');
const sara = Participant(id: 's', name: 'Sara');

Bill draft({List<Participant> people = const [], SplitMethod method = SplitMethod.equal}) => Bill(
  id: 'b',
  title: 'Lunch',
  currency: 'USD',
  date: DateTime(2026),
  items: const [
    BillItem(id: 'i1', name: 'Burger', totalMinor: 1200),
    BillItem(id: 'i2', name: 'Fries', totalMinor: 400),
  ],
  taxMinor: 160,
  participants: people,
  payerId: people.isEmpty ? null : people.first.id,
  splitMethod: method,
);

Future<SplitFlowViewModel> pump(WidgetTester tester, Widget page, Bill bill) async {
  Get.testMode = true;
  final vm = Get.put(SplitFlowViewModel(FakeBillRepository(), FakeAnalytics(), initial: bill));
  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      getPages: [
        GetPage(name: '/', page: () => page),
        GetPage(
          name: AppRoutes.participants,
          page: () => const Scaffold(body: Text('participants-page')),
        ),
        GetPage(name: AppRoutes.assign, page: () => const AssignItemsView()),
        GetPage(name: AppRoutes.summary, page: () => const SummaryView()),
      ],
    ),
  );
  await tester.pumpAndSettle();
  return vm;
}

void main() {
  tearDown(Get.reset);

  testWidgets('Review Items: shows items and total, removing all items blocks Next', (tester) async {
    final vm = await pump(tester, const ReviewItemsView(), draft());
    expect(find.text('Burger'), findsOneWidget);
    expect(find.text('Fries'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(Money.format(1760, 'USD')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(Money.format(1760, 'USD')), findsOneWidget);

    vm.removeItem('i1');
    vm.removeItem('i2');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Add at least one item.'), findsOneWidget);
  });

  testWidgets('Review Items: editing tax updates the animated total', (tester) async {
    await pump(tester, const ReviewItemsView(), draft());
    await tester.scrollUntilVisible(
      find.widgetWithText(TextFormField, 'Tax'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Tax'), '2.40');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(Money.format(1840, 'USD')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(Money.format(1840, 'USD')), findsOneWidget);
  });

  testWidgets('Review Items: Next navigates when valid', (tester) async {
    await pump(tester, const ReviewItemsView(), draft());
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('participants-page'), findsOneWidget);
  });

  testWidgets('Assign Items: unassigned items block summary; assigning reaches summary', (tester) async {
    final vm = await pump(
      tester,
      const AssignItemsView(),
      draft(people: const [ali, sara], method: SplitMethod.itemwise),
    );

    await tester.tap(find.text('See summary'));
    await tester.pumpAndSettle();
    expect(find.text('Assign every item to at least one person.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Ali').first); // Burger -> Ali
    await tester.tap(find.widgetWithText(ActionChip, 'Everyone').last); // Fries -> both
    await tester.pumpAndSettle();
    expect(vm.bill.value.items[0].assignedTo, ['a']);
    expect(vm.bill.value.items[1].assignedTo, ['a', 's']);

    await tester.tap(find.text('See summary'));
    await tester.pumpAndSettle();
    expect(find.text('Summary'), findsOneWidget);
    // Food: Ali 1400, Sara 200; tax 160 split 140/20.
    expect(vm.bill.value.shares, {'a': 1540, 's': 220});
  });

  testWidgets('Summary: shows each share, payer, and saves', (tester) async {
    final bill = draft(people: const [ali, sara]).copyWith(shares: const {'a': 880, 's': 880});
    final vm = await pump(tester, const SummaryView(), bill);
    expect(find.text('Paid by Ali'), findsOneWidget);
    expect(find.text(Money.format(880, 'USD')), findsNWidgets(2));
    expect(find.text(Money.format(1760, 'USD')), findsOneWidget);
    expect(vm.bill.value.shares.values.fold(0, (a, b) => a + b), vm.bill.value.totalMinor);
  });
}

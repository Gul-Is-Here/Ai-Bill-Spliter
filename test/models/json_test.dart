import 'package:ai_bill_spliter/core/errors/app_exception.dart';
import 'package:ai_bill_spliter/core/utils/money.dart';
import 'package:ai_bill_spliter/features/bill/models/bill.dart';
import 'package:ai_bill_spliter/features/bill/models/bill_item.dart';
import 'package:ai_bill_spliter/features/bill/models/participant.dart';
import 'package:ai_bill_spliter/features/groups/models/group.dart';
import 'package:ai_bill_spliter/features/groups/models/settlement.dart';
import 'package:ai_bill_spliter/features/scan/repositories/receipt_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bill JSON', () {
    test('round-trips every field', () {
      final bill = Bill(
        id: 'b1',
        title: 'Dinner',
        currency: 'PKR',
        date: DateTime.utc(2026, 11, 2, 20),
        items: const [BillItem(id: 'i1', name: 'Karahi', totalMinor: 250000, quantity: 1.5, assignedTo: ['a'])],
        participants: const [Participant(id: 'a', name: 'Ali')],
        taxMinor: 40000,
        tipMinor: 1000,
        serviceChargeMinor: 500,
        discountMinor: 200,
        splitMethod: SplitMethod.percentage,
        percentages: const {'a': 10000},
        shares: const {'a': 291300},
        payerId: 'a',
        groupId: 'g',
        receiptPath: 'users/u/receipts/b1.jpg',
        localImagePath: '/tmp/x.jpg',
        updatedAt: DateTime.utc(2026, 11, 3),
      );
      final copy = Bill.fromJson(bill.toJson());
      expect(copy.toJson(), bill.toJson());
      expect(copy.totalMinor, 291300);
    });

    test('tolerates missing optional fields and unknown enum values', () {
      final b = Bill.fromJson({'id': 'x', 'currency': 'USD', 'date': '2026-01-01T00:00:00.000', 'splitMethod': 'future'});
      expect(b.items, isEmpty);
      expect(b.splitMethod, SplitMethod.equal);
      expect(b.title, '');
    });
  });

  test('Group JSON round-trips with settlements', () {
    final g = Group(
      id: 'g',
      name: 'Naran trip',
      currency: 'PKR',
      createdAt: DateTime.utc(2026),
      type: GroupType.trip,
      members: const [Participant(id: 'm1', name: 'Sara')],
      settlements: [Settlement(id: 's', fromId: 'm1', toId: 'm2', amountMinor: 500, currency: 'PKR', date: DateTime.utc(2026))],
    );
    expect(Group.fromJson(g.toJson()).toJson(), g.toJson());
  });

  group('ReceiptParser', () {
    Bill parse(Map<String, dynamic> json) =>
        ReceiptParser.toBill(json, id: 'b', fallbackCurrency: 'PKR', receiptPath: 'p', now: DateTime(2026, 5, 5));

    test('maps a valid server response', () {
      final b = parse({
        'merchant': 'Kolachi',
        'currency': 'PKR',
        'date': '2026-11-01',
        'items': [
          {'name': 'Tea', 'quantity': 2, 'totalMinor': 30000},
        ],
        'taxMinor': 4800,
        'tipMinor': 0,
        'serviceChargeMinor': 0,
        'discountMinor': 0,
      });
      expect(b.title, 'Kolachi');
      expect(b.date, DateTime(2026, 11, 1));
      expect(b.items.single.quantity, 2);
      expect(b.totalMinor, 34800);
    });

    test('falls back on bad currency/date and ignores negative extras', () {
      final b = parse({
        'currency': 'Rs',
        'date': 'n/a',
        'items': [
          {'name': 'A', 'totalMinor': 100},
        ],
        'taxMinor': -5,
      });
      expect(b.currency, 'PKR');
      expect(b.date, DateTime(2026, 5, 5));
      expect(b.taxMinor, 0);
    });

    test('rejects missing or malformed items', () {
      expect(() => parse({'items': []}), throwsA(isA<AppException>()));
      expect(() => parse({'items': 'x'}), throwsA(isA<AppException>()));
      expect(
          () => parse({
                'items': [
                  {'name': '', 'totalMinor': 1},
                ],
              }),
          throwsA(isA<AppException>()));
      expect(
          () => parse({
                'items': [
                  {'name': 'A', 'totalMinor': -1},
                ],
              }),
          throwsA(isA<AppException>()));
    });
  });

  group('Money', () {
    test('parses and formats minor units', () {
      expect(Money.parse('1,250.50', 'USD'), 125050);
      expect(Money.parse('-1', 'USD'), isNull);
      expect(Money.parse('abc', 'USD'), isNull);
      expect(Money.toInput(125050, 'USD'), '1250.50');
      expect(Money.parse('980', 'JPY'), 980);
    });
  });
}

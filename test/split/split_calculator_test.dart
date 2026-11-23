import 'dart:math';

import 'package:ai_bill_spliter/features/bill/models/bill.dart';
import 'package:ai_bill_spliter/features/bill/models/bill_item.dart';
import 'package:ai_bill_spliter/features/bill/models/participant.dart';
import 'package:ai_bill_spliter/features/split/services/split_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

const a = Participant(id: 'a', name: 'Ali');
const b = Participant(id: 'b', name: 'Sara');
const c = Participant(id: 'c', name: 'Omar');

Bill bill({
  List<BillItem> items = const [],
  SplitMethod method = SplitMethod.equal,
  int tax = 0,
  int tip = 0,
  int service = 0,
  int discount = 0,
  Map<String, int> percentages = const {},
  List<Participant> people = const [a, b, c],
}) =>
    Bill(
      id: 'x',
      title: 't',
      currency: 'PKR',
      date: DateTime(2026),
      items: items,
      participants: people,
      splitMethod: method,
      taxMinor: tax,
      tipMinor: tip,
      serviceChargeMinor: service,
      discountMinor: discount,
      percentages: percentages,
    );

int sum(Map<String, int> m) => m.values.fold(0, (x, y) => x + y);

void main() {
  group('allocate', () {
    test('splits 100 three ways with remainder to first', () {
      expect(SplitCalculator.allocate(100, [1, 1, 1]), [34, 33, 33]);
    });

    test('handles negative amounts symmetrically', () {
      expect(SplitCalculator.allocate(-100, [1, 1, 1]), [-34, -33, -33]);
    });

    test('weighted with largest remainder', () {
      expect(SplitCalculator.allocate(10, [1, 2]), [3, 7]);
    });

    test('zero weight gets nothing', () {
      expect(SplitCalculator.allocate(99, [0, 1, 2]), [0, 33, 66]);
    });

    test('rejects bad weights', () {
      expect(() => SplitCalculator.allocate(1, []), throwsArgumentError);
      expect(() => SplitCalculator.allocate(1, [0, 0]), throwsArgumentError);
    });

    test('always sums exactly (randomized)', () {
      final rnd = Random(42);
      for (var n = 0; n < 2000; n++) {
        final amount = rnd.nextInt(10000000) - 1000;
        final weights = List.generate(1 + rnd.nextInt(9), (_) => rnd.nextInt(5000));
        if (weights.every((w) => w == 0)) weights[0] = 1;
        final parts = SplitCalculator.allocate(amount, weights);
        expect(parts.fold(0, (x, y) => x + y), amount);
      }
    });
  });

  group('equal split', () {
    test('includes tax, tip, service and discount', () {
      final r = SplitCalculator.calculate(bill(
        items: const [BillItem(id: '1', name: 'Pizza', totalMinor: 100000)],
        tax: 16000,
        tip: 5000,
        service: 1001,
        discount: 2000,
      ));
      expect(sum(r), 120001);
      expect(r, {'a': 40001, 'b': 40000, 'c': 40000});
    });
  });

  group('percentage split', () {
    test('50/30/20 of an odd total', () {
      final r = SplitCalculator.calculate(bill(
        items: const [BillItem(id: '1', name: 'X', totalMinor: 1001)],
        method: SplitMethod.percentage,
        percentages: const {'a': 5000, 'b': 3000, 'c': 2000},
      ));
      expect(r, {'a': 501, 'b': 300, 'c': 200});
      expect(sum(r), 1001);
    });

    test('rejects percentages not summing to 100%', () {
      expect(
        () => SplitCalculator.calculate(bill(
          items: const [BillItem(id: '1', name: 'X', totalMinor: 100)],
          method: SplitMethod.percentage,
          percentages: const {'a': 5000, 'b': 3000},
        )),
        throwsA(isA<SplitException>()),
      );
    });
  });

  group('itemwise split', () {
    test('shared item splits evenly, extras proportional to food', () {
      final r = SplitCalculator.calculate(bill(
        items: const [
          BillItem(id: '1', name: 'Steak', totalMinor: 3000, assignedTo: ['a']),
          BillItem(id: '2', name: 'Salad', totalMinor: 1000, assignedTo: ['b']),
          BillItem(id: '3', name: 'Fries', totalMinor: 1000, assignedTo: ['a', 'b', 'c']),
        ],
        method: SplitMethod.itemwise,
        tax: 500,
        tip: 250,
      ));
      // Food: a=3334, b=1333, c=333 (5000). Extras 750 by those weights.
      expect(r, {'a': 3334 + 500, 'b': 1333 + 200, 'c': 333 + 50});
      expect(sum(r), 5750);
    });

    test('discount larger than tax reduces shares and still sums', () {
      final r = SplitCalculator.calculate(bill(
        items: const [
          BillItem(id: '1', name: 'A', totalMinor: 999, assignedTo: ['a']),
          BillItem(id: '2', name: 'B', totalMinor: 1, assignedTo: ['b']),
        ],
        method: SplitMethod.itemwise,
        tax: 10,
        discount: 110,
        people: const [a, b],
      ));
      expect(sum(r), 900);
      expect(r['a']! + r['b']!, 900);
    });

    test('unassigned item is an error', () {
      expect(
        () => SplitCalculator.calculate(bill(
          items: const [BillItem(id: '1', name: 'A', totalMinor: 100)],
          method: SplitMethod.itemwise,
        )),
        throwsA(isA<SplitException>()),
      );
    });

    test('assignments to removed participants are ignored', () {
      final r = SplitCalculator.calculate(bill(
        items: const [BillItem(id: '1', name: 'A', totalMinor: 100, assignedTo: ['a', 'gone'])],
        method: SplitMethod.itemwise,
        people: const [a, b],
      ));
      expect(r, {'a': 100, 'b': 0});
    });

    test('zero-cost items only: extras split equally', () {
      final r = SplitCalculator.calculate(bill(
        items: const [BillItem(id: '1', name: 'Free', totalMinor: 0, assignedTo: ['a'])],
        method: SplitMethod.itemwise,
        service: 100,
      ));
      expect(r, {'a': 34, 'b': 33, 'c': 33});
    });
  });

  test('no participants and negative totals are errors', () {
    expect(() => SplitCalculator.calculate(bill(people: const [])), throwsA(isA<SplitException>()));
    expect(
      () => SplitCalculator.calculate(bill(items: const [BillItem(id: '1', name: 'A', totalMinor: 10)], discount: 20)),
      throwsA(isA<SplitException>()),
    );
  });
}

import 'dart:math';

import 'package:ai_bill_spliter/features/bill/models/bill.dart';
import 'package:ai_bill_spliter/features/groups/models/settlement.dart';
import 'package:ai_bill_spliter/features/groups/services/settlement_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

Bill paid(String payer, Map<String, int> shares, {String currency = 'PKR'}) => Bill(
      id: '${payer}_${shares.hashCode}',
      title: '',
      currency: currency,
      date: DateTime(2026),
      payerId: payer,
      shares: shares,
    );

void main() {
  test('balances: payer is owed everyone else\'s share', () {
    final b = SettlementCalculator.balances([paid('a', {'a': 100, 'b': 100, 'c': 100})], const []);
    expect(b['PKR'], {'a': 200, 'b': -100, 'c': -100});
  });

  test('recorded payments reduce balances', () {
    final b = SettlementCalculator.balances(
      [paid('a', {'a': 100, 'b': 100})],
      const [Settlement(fromId: 'b', toId: 'a', amountMinor: 60, currency: 'PKR')],
    );
    expect(b['PKR'], {'a': 40, 'b': -40});
  });

  test('chain a->b->c collapses to one transfer', () {
    // b paid for a (a owes b 50); c paid for b (b owes c 50) => a pays c.
    final balances = SettlementCalculator.balances([
      paid('b', {'a': 50}),
      paid('c', {'b': 50}),
    ], const []);
    expect(SettlementCalculator.minimize(balances), const [
      Settlement(fromId: 'a', toId: 'c', amountMinor: 50, currency: 'PKR'),
    ]);
  });

  test('currencies are settled separately', () {
    final balances = SettlementCalculator.balances([
      paid('a', {'b': 10}, currency: 'USD'),
      paid('b', {'a': 500}),
    ], const []);
    expect(SettlementCalculator.minimize(balances), const [
      Settlement(fromId: 'a', toId: 'b', amountMinor: 500, currency: 'PKR'),
      Settlement(fromId: 'b', toId: 'a', amountMinor: 10, currency: 'USD'),
    ]);
  });

  test('fully settled group needs no transfers', () {
    final balances = SettlementCalculator.balances(
      [paid('a', {'a': 50, 'b': 50})],
      const [Settlement(fromId: 'b', toId: 'a', amountMinor: 50, currency: 'PKR')],
    );
    expect(SettlementCalculator.minimize(balances), isEmpty);
  });

  test('randomized: transfers settle every balance with at most n-1 payments', () {
    final rnd = Random(7);
    for (var run = 0; run < 300; run++) {
      final people = List.generate(2 + rnd.nextInt(8), (i) => 'p$i');
      final bills = List.generate(1 + rnd.nextInt(10), (_) {
        final payer = people[rnd.nextInt(people.length)];
        return paid(payer, {for (final p in people) if (rnd.nextBool()) p: rnd.nextInt(100000)});
      });
      final balances = SettlementCalculator.balances(bills, const []);
      final transfers = SettlementCalculator.minimize(balances);
      final after = SettlementCalculator.balances(bills, transfers);
      expect(after['PKR']?.values.every((v) => v == 0) ?? true, isTrue);
      expect(transfers.length, lessThanOrEqualTo(people.length - 1));
      expect(transfers.every((t) => t.amountMinor > 0), isTrue);
    }
  });
}

import '../../bill/models/bill.dart';
import '../models/settlement.dart';

/// Group balances and the minimal set of payments to settle them.
abstract class SettlementCalculator {
  /// Net balance per member per currency: positive = is owed money, negative = owes.
  static Map<String, Map<String, int>> balances(Iterable<Bill> bills, Iterable<Settlement> payments) {
    final result = <String, Map<String, int>>{};
    void add(String currency, String id, int delta) {
      final m = result.putIfAbsent(currency, () => {});
      m[id] = (m[id] ?? 0) + delta;
    }

    for (final bill in bills) {
      final payer = bill.payerId;
      if (payer == null || bill.shares.isEmpty) continue;
      for (final entry in bill.shares.entries) {
        add(bill.currency, entry.key, -entry.value);
      }
      add(bill.currency, payer, bill.shares.values.fold(0, (a, b) => a + b));
    }
    for (final p in payments) {
      add(p.currency, p.fromId, p.amountMinor);
      add(p.currency, p.toId, -p.amountMinor);
    }
    return result;
  }

  /// Greedy debt minimization: repeatedly match the largest debtor with the largest creditor.
  /// Produces at most n-1 transfers per currency; ties broken by id for stable output.
  static List<Settlement> minimize(Map<String, Map<String, int>> balances) {
    final transfers = <Settlement>[];
    final currencies = balances.keys.toList()..sort();
    for (final currency in currencies) {
      final debtors = <MapEntry<String, int>>[];
      final creditors = <MapEntry<String, int>>[];
      balances[currency]!.forEach((id, v) {
        if (v < 0) debtors.add(MapEntry(id, -v));
        if (v > 0) creditors.add(MapEntry(id, v));
      });
      int byAmount(MapEntry<String, int> a, MapEntry<String, int> b) {
        final c = b.value.compareTo(a.value);
        return c != 0 ? c : a.key.compareTo(b.key);
      }

      while (debtors.isNotEmpty && creditors.isNotEmpty) {
        debtors.sort(byAmount);
        creditors.sort(byAmount);
        final d = debtors.first;
        final c = creditors.first;
        final amount = d.value < c.value ? d.value : c.value;
        transfers.add(Settlement(fromId: d.key, toId: c.key, amountMinor: amount, currency: currency));
        debtors[0] = MapEntry(d.key, d.value - amount);
        creditors[0] = MapEntry(c.key, c.value - amount);
        debtors.removeWhere((e) => e.value == 0);
        creditors.removeWhere((e) => e.value == 0);
      }
    }
    return transfers;
  }
}

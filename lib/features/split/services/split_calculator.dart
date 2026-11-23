import '../../bill/models/bill.dart';

class SplitException implements Exception {
  const SplitException(this.messageKey);
  final String messageKey;
}

/// Pure split math in integer minor units. Every result sums exactly to the bill total.
abstract class SplitCalculator {
  static const fullPercent = 10000; // basis points

  static Map<String, int> calculate(Bill bill) {
    final people = bill.participants.map((p) => p.id).toList();
    if (people.isEmpty) throw const SplitException('error_no_participants');
    if (bill.totalMinor < 0) throw const SplitException('error_negative_total');

    final amounts = switch (bill.splitMethod) {
      SplitMethod.equal => allocate(bill.totalMinor, List.filled(people.length, 1)),
      SplitMethod.percentage => _percentage(bill, people),
      SplitMethod.itemwise => _itemwise(bill, people),
    };
    return {for (var i = 0; i < people.length; i++) people[i]: amounts[i]};
  }

  static List<int> _percentage(Bill bill, List<String> people) {
    final weights = people.map((id) => bill.percentages[id] ?? 0).toList();
    if (weights.any((w) => w < 0) || weights.fold(0, (a, b) => a + b) != fullPercent) {
      throw const SplitException('error_percent_sum');
    }
    return allocate(bill.totalMinor, weights);
  }

  static List<int> _itemwise(Bill bill, List<String> people) {
    final index = {for (var i = 0; i < people.length; i++) people[i]: i};
    final subtotals = List.filled(people.length, 0);
    for (final item in bill.items) {
      final owners = item.assignedTo.where(index.containsKey).toList();
      if (owners.isEmpty) throw const SplitException('error_unassigned_items');
      final parts = allocate(item.totalMinor, List.filled(owners.length, 1));
      for (var j = 0; j < owners.length; j++) {
        subtotals[index[owners[j]]!] += parts[j];
      }
    }
    // Tax, tip, service and discount follow each person's share of the food.
    final hasFood = subtotals.any((s) => s > 0);
    final extras = allocate(bill.extrasMinor, hasFood ? subtotals : List.filled(people.length, 1));
    return [for (var i = 0; i < people.length; i++) subtotals[i] + extras[i]];
  }

  /// Largest-remainder apportionment: splits [amount] by [weights] so parts sum exactly to [amount].
  /// Leftover units go to the largest fractional remainders, ties to the earliest index.
  static List<int> allocate(int amount, List<int> weights) {
    if (weights.isEmpty) throw ArgumentError('weights must not be empty');
    if (amount < 0) return allocate(-amount, weights).map((v) => -v).toList();
    final totalWeight = weights.fold(0, (a, b) => a + b);
    if (totalWeight <= 0) throw ArgumentError('weights must sum to a positive number');

    final parts = List.filled(weights.length, 0);
    final remainders = List.filled(weights.length, 0);
    var assigned = 0;
    for (var i = 0; i < weights.length; i++) {
      final exact = amount * weights[i];
      parts[i] = exact ~/ totalWeight;
      remainders[i] = exact % totalWeight;
      assigned += parts[i];
    }
    final order = List.generate(weights.length, (i) => i)
      ..sort((a, b) {
        final byRemainder = remainders[b].compareTo(remainders[a]);
        return byRemainder != 0 ? byRemainder : a.compareTo(b);
      });
    for (var k = 0; k < amount - assigned; k++) {
      parts[order[k]]++;
    }
    return parts;
  }
}

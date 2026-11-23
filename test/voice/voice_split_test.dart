import 'package:ai_bill_spliter/core/errors/app_exception.dart';
import 'package:ai_bill_spliter/features/bill/models/bill.dart';
import 'package:ai_bill_spliter/features/bill/models/bill_item.dart';
import 'package:ai_bill_spliter/features/bill/models/participant.dart';
import 'package:ai_bill_spliter/features/split/services/split_calculator.dart';
import 'package:ai_bill_spliter/features/voice/models/voice_split_result.dart';
import 'package:ai_bill_spliter/features/voice/services/voice_split_applier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final bill = Bill(
    id: 'b',
    title: '',
    currency: 'PKR',
    date: DateTime(2026),
    items: const [
      BillItem(id: 'i0', name: 'Burger', totalMinor: 1000),
      BillItem(id: 'i1', name: 'Pizza', totalMinor: 2000),
    ],
    participants: const [Participant(id: 'p0', name: 'Ali')],
  );

  test('parses server JSON', () {
    final r = VoiceSplitResult.fromJson({
      'participants': ['Ali', 'Sara', 'Me'],
      'payer': 'Sara',
      'method': 'itemwise',
      'assignments': [
        {'itemIndex': 0, 'names': ['Ali']},
        {'itemIndex': 1, 'names': ['Sara', 'Me']},
      ],
      'percentages': [],
    });
    expect(r.method, SplitMethod.itemwise);
    expect(r.assignments[1], ['Sara', 'Me']);
  });

  test('rejects malformed JSON', () {
    expect(() => VoiceSplitResult.fromJson({'participants': [], 'method': 'equal'}), throwsA(isA<AppException>()));
    expect(() => VoiceSplitResult.fromJson({'participants': ['A'], 'method': 'nope'}), throwsA(isA<AppException>()));
    expect(() => VoiceSplitResult.fromJson({'participants': [1], 'method': 'equal'}), throwsA(isA<AppException>()));
  });

  test('applies itemwise result, reusing existing people and mapping "Me"', () {
    var n = 0;
    final out = VoiceSplitApplier.apply(
      bill,
      const VoiceSplitResult(
        participants: ['ali', 'Sara', 'Me'],
        method: SplitMethod.itemwise,
        payer: 'Sara',
        assignments: {0: ['Ali'], 1: ['Sara', 'Me']},
      ),
      () => 'new${n++}',
      meLabel: 'You',
    );
    expect(out.participants.map((p) => p.name), ['Ali', 'Sara', 'You']);
    expect(out.items[0].assignedTo, ['p0']);
    expect(out.items[1].assignedTo, ['new0', 'new1']);
    expect(out.payerId, 'new0');
    final shares = SplitCalculator.calculate(out);
    expect(shares, {'p0': 1000, 'new0': 1000, 'new1': 1000});
  });

  test('applies percentages', () {
    final out = VoiceSplitApplier.apply(
      bill,
      const VoiceSplitResult(
        participants: ['Ali', 'Sara'],
        method: SplitMethod.percentage,
        percentages: {'Ali': 7000, 'Sara': 3000},
      ),
      () => 's',
      meLabel: 'You',
    );
    expect(out.percentages, {'p0': 7000, 's': 3000});
    expect(SplitCalculator.calculate(out), {'p0': 2100, 's': 900});
  });
}

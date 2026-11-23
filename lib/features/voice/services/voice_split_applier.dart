import '../../bill/models/bill.dart';
import '../../bill/models/participant.dart';
import '../models/voice_split_result.dart';

/// Merges a voice result into a bill draft. Existing people are matched by name (case-insensitive).
abstract class VoiceSplitApplier {
  static Bill apply(Bill bill, VoiceSplitResult result, String Function() newId, {required String meLabel}) {
    final people = [...bill.participants];
    final idByName = {for (final p in people) p.name.toLowerCase(): p.id};

    String resolve(String spoken) {
      final name = spoken.toLowerCase() == 'me' ? meLabel : spoken;
      return idByName.putIfAbsent(name.toLowerCase(), () {
        final p = Participant(id: newId(), name: name);
        people.add(p);
        return p.id;
      });
    }

    for (final name in result.participants) {
      resolve(name);
    }

    final items = [
      for (var i = 0; i < bill.items.length; i++)
        result.assignments.containsKey(i)
            ? bill.items[i].copyWith(assignedTo: result.assignments[i]!.map(resolve).toSet().toList())
            : bill.items[i],
    ];

    return bill.copyWith(
      participants: people,
      items: items,
      splitMethod: result.method,
      payerId: result.payer != null ? resolve(result.payer!) : bill.payerId ?? people.firstOrNull?.id,
      percentages: result.method == SplitMethod.percentage
          ? {for (final e in result.percentages.entries) resolve(e.key): e.value}
          : bill.percentages,
    );
  }
}

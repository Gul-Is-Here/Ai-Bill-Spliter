import '../../../core/errors/app_exception.dart';
import '../../bill/models/bill.dart';

class VoiceSplitResult {
  const VoiceSplitResult({
    required this.participants,
    required this.method,
    this.payer,
    this.assignments = const {},
    this.percentages = const {},
  });

  /// Throws [AppException] if the payload is not the shape the server promises.
  factory VoiceSplitResult.fromJson(Map<String, dynamic> json) {
    final people = json['participants'];
    final method = SplitMethod.values.asNameMap()[json['method']];
    if (people is! List || people.isEmpty || people.any((p) => p is! String) || method == null) {
      throw const AppException('error_voice_not_understood');
    }
    final assignments = <int, List<String>>{};
    for (final a in json['assignments'] as List? ?? const []) {
      if (a is Map && a['itemIndex'] is int && a['names'] is List) {
        assignments[a['itemIndex'] as int] = List<String>.from((a['names'] as List).whereType<String>());
      }
    }
    final percentages = <String, int>{};
    for (final p in json['percentages'] as List? ?? const []) {
      if (p is Map && p['name'] is String && p['basisPoints'] is num) {
        percentages[p['name'] as String] = (p['basisPoints'] as num).toInt();
      }
    }
    return VoiceSplitResult(
      participants: List<String>.from(people),
      method: method,
      payer: json['payer'] as String?,
      assignments: assignments,
      percentages: percentages,
    );
  }

  final List<String> participants;
  final SplitMethod method;
  final String? payer;

  /// Item index -> participant names.
  final Map<int, List<String>> assignments;

  /// Participant name -> basis points.
  final Map<String, int> percentages;
}

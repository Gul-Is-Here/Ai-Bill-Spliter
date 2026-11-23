import '../../bill/models/participant.dart';
import 'settlement.dart';

enum GroupType { trip, home, friends, other }

class Group {
  const Group({
    required this.id,
    required this.name,
    required this.currency,
    required this.createdAt,
    this.type = GroupType.friends,
    this.members = const [],
    this.settlements = const [],
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json['id'] as String,
        name: json['name'] as String,
        currency: json['currency'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        type: GroupType.values.asNameMap()[json['type']] ?? GroupType.other,
        members: (json['members'] as List? ?? const [])
            .map((e) => Participant.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        settlements: (json['settlements'] as List? ?? const [])
            .map((e) => Settlement.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  final String id;
  final String name;
  final String currency;
  final DateTime createdAt;
  final GroupType type;
  final List<Participant> members;

  /// Recorded payments between members ("Ali paid Sara 500").
  final List<Settlement> settlements;

  Group copyWith({String? name, String? currency, GroupType? type, List<Participant>? members, List<Settlement>? settlements}) =>
      Group(
        id: id,
        name: name ?? this.name,
        currency: currency ?? this.currency,
        createdAt: createdAt,
        type: type ?? this.type,
        members: members ?? this.members,
        settlements: settlements ?? this.settlements,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'currency': currency,
        'createdAt': createdAt.toIso8601String(),
        'type': type.name,
        'members': members.map((m) => m.toJson()).toList(),
        'settlements': settlements.map((s) => s.toJson()).toList(),
      };
}

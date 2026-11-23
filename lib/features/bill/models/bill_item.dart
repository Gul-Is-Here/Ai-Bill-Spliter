class BillItem {
  const BillItem({
    required this.id,
    required this.name,
    required this.totalMinor,
    this.quantity = 1,
    this.assignedTo = const [],
  });

  factory BillItem.fromJson(Map<String, dynamic> json) => BillItem(
        id: json['id'] as String,
        name: json['name'] as String,
        totalMinor: (json['totalMinor'] as num).toInt(),
        quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
        assignedTo: List<String>.from(json['assignedTo'] as List? ?? const []),
      );

  final String id;
  final String name;
  final double quantity;

  /// Line total for all units, minor currency units.
  final int totalMinor;

  /// Participant ids sharing this item (split evenly between them).
  final List<String> assignedTo;

  BillItem copyWith({String? name, double? quantity, int? totalMinor, List<String>? assignedTo}) => BillItem(
        id: id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        totalMinor: totalMinor ?? this.totalMinor,
        assignedTo: assignedTo ?? this.assignedTo,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'totalMinor': totalMinor,
        'assignedTo': assignedTo,
      };
}

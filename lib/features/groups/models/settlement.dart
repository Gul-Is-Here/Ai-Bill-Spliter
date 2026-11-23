/// A payment of [amountMinor] from [fromId] to [toId]. Also used for suggested transfers.
class Settlement {
  const Settlement({
    required this.fromId,
    required this.toId,
    required this.amountMinor,
    required this.currency,
    this.id = '',
    this.date,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) => Settlement(
        id: json['id'] as String? ?? '',
        fromId: json['fromId'] as String,
        toId: json['toId'] as String,
        amountMinor: (json['amountMinor'] as num).toInt(),
        currency: json['currency'] as String,
        date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
      );

  final String id;
  final String fromId;
  final String toId;
  final int amountMinor;
  final String currency;
  final DateTime? date;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromId': fromId,
        'toId': toId,
        'amountMinor': amountMinor,
        'currency': currency,
        'date': date?.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      other is Settlement &&
      other.fromId == fromId &&
      other.toId == toId &&
      other.amountMinor == amountMinor &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(fromId, toId, amountMinor, currency);

  @override
  String toString() => '$fromId->$toId:$amountMinor $currency';
}

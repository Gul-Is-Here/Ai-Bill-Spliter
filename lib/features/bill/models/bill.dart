import 'bill_item.dart';
import 'participant.dart';

enum SplitMethod { equal, itemwise, percentage }

class Bill {
  const Bill({
    required this.id,
    required this.title,
    required this.currency,
    required this.date,
    this.items = const [],
    this.participants = const [],
    this.taxMinor = 0,
    this.tipMinor = 0,
    this.serviceChargeMinor = 0,
    this.discountMinor = 0,
    this.splitMethod = SplitMethod.equal,
    this.percentages = const {},
    this.shares = const {},
    this.payerId,
    this.groupId,
    this.receiptPath,
    this.localImagePath,
    this.updatedAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        currency: json['currency'] as String,
        date: DateTime.parse(json['date'] as String),
        items: (json['items'] as List? ?? const [])
            .map((e) => BillItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        participants: (json['participants'] as List? ?? const [])
            .map((e) => Participant.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        taxMinor: (json['taxMinor'] as num?)?.toInt() ?? 0,
        tipMinor: (json['tipMinor'] as num?)?.toInt() ?? 0,
        serviceChargeMinor: (json['serviceChargeMinor'] as num?)?.toInt() ?? 0,
        discountMinor: (json['discountMinor'] as num?)?.toInt() ?? 0,
        splitMethod: SplitMethod.values.asNameMap()[json['splitMethod']] ?? SplitMethod.equal,
        percentages: Map<String, int>.from(
            (json['percentages'] as Map? ?? const {}).map((k, v) => MapEntry(k as String, (v as num).toInt()))),
        shares: Map<String, int>.from(
            (json['shares'] as Map? ?? const {}).map((k, v) => MapEntry(k as String, (v as num).toInt()))),
        payerId: json['payerId'] as String?,
        groupId: json['groupId'] as String?,
        receiptPath: json['receiptPath'] as String?,
        localImagePath: json['localImagePath'] as String?,
        updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
      );

  final String id;
  final String title;
  final String currency;
  final DateTime date;
  final List<BillItem> items;
  final List<Participant> participants;
  final int taxMinor;
  final int tipMinor;
  final int serviceChargeMinor;
  final int discountMinor;
  final SplitMethod splitMethod;

  /// Participant id -> basis points (10000 = 100%). Used by [SplitMethod.percentage].
  final Map<String, int> percentages;

  /// Computed result: participant id -> amount owed (minor units). Sums to [totalMinor].
  final Map<String, int> shares;
  final String? payerId;
  final String? groupId;

  /// Storage path of the uploaded receipt image.
  final String? receiptPath;

  /// On-device image awaiting upload (offline queue).
  final String? localImagePath;
  final DateTime? updatedAt;

  int get subtotalMinor => items.fold(0, (sum, i) => sum + i.totalMinor);

  int get extrasMinor => taxMinor + tipMinor + serviceChargeMinor - discountMinor;

  int get totalMinor => subtotalMinor + extrasMinor;

  Bill copyWith({
    String? title,
    String? currency,
    DateTime? date,
    List<BillItem>? items,
    List<Participant>? participants,
    int? taxMinor,
    int? tipMinor,
    int? serviceChargeMinor,
    int? discountMinor,
    SplitMethod? splitMethod,
    Map<String, int>? percentages,
    Map<String, int>? shares,
    String? payerId,
    String? groupId,
    String? receiptPath,
    String? localImagePath,
    bool clearLocalImage = false,
    DateTime? updatedAt,
  }) =>
      Bill(
        id: id,
        title: title ?? this.title,
        currency: currency ?? this.currency,
        date: date ?? this.date,
        items: items ?? this.items,
        participants: participants ?? this.participants,
        taxMinor: taxMinor ?? this.taxMinor,
        tipMinor: tipMinor ?? this.tipMinor,
        serviceChargeMinor: serviceChargeMinor ?? this.serviceChargeMinor,
        discountMinor: discountMinor ?? this.discountMinor,
        splitMethod: splitMethod ?? this.splitMethod,
        percentages: percentages ?? this.percentages,
        shares: shares ?? this.shares,
        payerId: payerId ?? this.payerId,
        groupId: groupId ?? this.groupId,
        receiptPath: receiptPath ?? this.receiptPath,
        localImagePath: clearLocalImage ? null : (localImagePath ?? this.localImagePath),
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'currency': currency,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'participants': participants.map((e) => e.toJson()).toList(),
        'taxMinor': taxMinor,
        'tipMinor': tipMinor,
        'serviceChargeMinor': serviceChargeMinor,
        'discountMinor': discountMinor,
        'splitMethod': splitMethod.name,
        'percentages': percentages,
        'shares': shares,
        'payerId': payerId,
        'groupId': groupId,
        'receiptPath': receiptPath,
        'localImagePath': localImagePath,
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

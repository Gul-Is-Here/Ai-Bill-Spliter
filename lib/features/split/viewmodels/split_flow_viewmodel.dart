import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/analytics_service.dart';
import '../../bill/models/bill.dart';
import '../../bill/models/bill_item.dart';
import '../../bill/models/participant.dart';
import '../../bill/repositories/bill_repository.dart';
import '../../settings/repositories/settings_repository.dart';
import '../../voice/models/voice_split_result.dart';
import '../../voice/services/voice_split_applier.dart';
import '../services/split_calculator.dart';

/// Owns the bill draft across Review → Participants → Assign → Summary.
class SplitFlowViewModel extends GetxController {
  SplitFlowViewModel(this._repository, this._analytics, {Bill? initial})
      : bill = (initial ?? Get.arguments as Bill).obs;

  final BillRepository _repository;

  static const _flowRoutes = {AppRoutes.reviewItems, AppRoutes.participants, AppRoutes.assign, AppRoutes.summary};
  final AnalyticsService _analytics;

  final Rx<Bill> bill;
  final isSaving = false.obs;
  final errorKey = RxnString();
  var _idCounter = 0;

  String _newId(String prefix) => '$prefix${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

  // Review items

  void setTitle(String title) => bill.value = bill.value.copyWith(title: title.trim());

  void setCurrency(String currency) => bill.value = bill.value.copyWith(currency: currency);

  void addItem(String name, int totalMinor, double quantity) {
    bill.value = bill.value.copyWith(items: [
      ...bill.value.items,
      BillItem(id: _newId('i'), name: name.trim(), totalMinor: totalMinor, quantity: quantity),
    ]);
  }

  void updateItem(String id, {required String name, required int totalMinor, required double quantity}) {
    bill.value = bill.value.copyWith(
      items: [
        for (final i in bill.value.items)
          i.id == id ? i.copyWith(name: name.trim(), totalMinor: totalMinor, quantity: quantity) : i,
      ],
    );
  }

  void removeItem(String id) =>
      bill.value = bill.value.copyWith(items: bill.value.items.where((i) => i.id != id).toList());

  void setExtras({int? tax, int? tip, int? serviceCharge, int? discount}) {
    bill.value = bill.value.copyWith(
      taxMinor: tax,
      tipMinor: tip,
      serviceChargeMinor: serviceCharge,
      discountMinor: discount,
    );
  }

  /// Translation key of the problem blocking the next step, or null.
  String? get reviewError {
    final b = bill.value;
    if (b.items.isEmpty) return 'error_no_items';
    if (b.totalMinor < 0) return 'error_negative_total';
    return null;
  }

  void continueFromReview() {
    errorKey.value = reviewError;
    if (errorKey.value == null) Get.toNamed(AppRoutes.participants);
  }

  // Participants

  void addParticipant(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final p = Participant(id: _newId('p'), name: trimmed);
    bill.value = bill.value.copyWith(
      participants: [...bill.value.participants, p],
      payerId: bill.value.payerId ?? p.id,
    );
  }

  void addParticipants(Iterable<Participant> people) {
    final existing = bill.value.participants.map((p) => p.id).toSet();
    final added = people.where((p) => !existing.contains(p.id)).toList();
    if (added.isEmpty) return;
    bill.value = bill.value.copyWith(
      participants: [...bill.value.participants, ...added],
      payerId: bill.value.payerId ?? added.first.id,
    );
  }

  void removeParticipant(String id) {
    final b = bill.value;
    final remaining = b.participants.where((p) => p.id != id).toList();
    bill.value = Bill.fromJson({
      ...b.toJson(),
      'participants': remaining.map((p) => p.toJson()).toList(),
      'items': [for (final i in b.items) i.copyWith(assignedTo: i.assignedTo.where((x) => x != id).toList()).toJson()],
      'percentages': Map.of(b.percentages)..remove(id),
      'payerId': b.payerId == id ? (remaining.isEmpty ? null : remaining.first.id) : b.payerId,
    });
  }

  void applyVoice(VoiceSplitResult result) {
    bill.value = VoiceSplitApplier.apply(bill.value, result, () => _newId('p'), meLabel: 'me'.tr);
    errorKey.value = null;
  }

  void setPayer(String id) => bill.value = bill.value.copyWith(payerId: id);

  void setMethod(SplitMethod method) {
    var b = bill.value.copyWith(splitMethod: method);
    if (method == SplitMethod.percentage && b.percentages.isEmpty) b = b.copyWith(percentages: _evenPercentages(b));
    bill.value = b;
  }

  String? get participantsError => bill.value.participants.length < 2 ? 'error_min_participants' : null;

  void continueFromParticipants() {
    errorKey.value = participantsError;
    if (errorKey.value != null) return;
    if (bill.value.splitMethod == SplitMethod.equal) {
      _goToSummary();
    } else {
      Get.toNamed(AppRoutes.assign);
    }
  }

  // Assign (itemwise / percentage)

  void toggleAssignment(String itemId, String participantId) {
    HapticFeedback.selectionClick();
    bill.value = bill.value.copyWith(items: [
      for (final i in bill.value.items)
        if (i.id != itemId)
          i
        else
          i.copyWith(
            assignedTo: i.assignedTo.contains(participantId)
                ? i.assignedTo.where((x) => x != participantId).toList()
                : [...i.assignedTo, participantId],
          ),
    ]);
  }

  void assignToEveryone(String itemId) {
    final everyone = bill.value.participants.map((p) => p.id).toList();
    bill.value = bill.value.copyWith(items: [
      for (final i in bill.value.items) i.id == itemId ? i.copyWith(assignedTo: everyone) : i,
    ]);
  }

  void setPercentage(String participantId, int basisPoints) {
    bill.value = bill.value.copyWith(
      percentages: {...bill.value.percentages, participantId: basisPoints.clamp(0, SplitCalculator.fullPercent)},
    );
  }

  void evenPercentages() => bill.value = bill.value.copyWith(percentages: _evenPercentages(bill.value));

  Map<String, int> _evenPercentages(Bill b) {
    final parts = SplitCalculator.allocate(SplitCalculator.fullPercent, List.filled(b.participants.length, 1));
    return {for (var i = 0; i < b.participants.length; i++) b.participants[i].id: parts[i]};
  }

  int get percentTotal => bill.value.percentages.values.fold(0, (a, b) => a + b);

  void continueFromAssign() => _goToSummary();

  void _goToSummary() {
    try {
      bill.value = bill.value.copyWith(shares: SplitCalculator.calculate(bill.value));
      errorKey.value = null;
      Get.toNamed(AppRoutes.summary);
    } on SplitException catch (e) {
      errorKey.value = e.messageKey;
    }
  }

  // Summary

  Future<void> save() async {
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      bill.value = await _repository.save(bill.value);
      _analytics.log(AnalyticsEvent.billSplit, {
        'method': bill.value.splitMethod.name,
        'people': bill.value.participants.length,
      });
      HapticFeedback.heavyImpact();
      if (await Get.find<SettingsRepository>().registerSplitAndShouldAskReview() &&
          await InAppReview.instance.isAvailable()) {
        InAppReview.instance.requestReview();
      }
      // Return to wherever the flow started (home or a group).
      Get.until((route) => !_flowRoutes.contains(route.settings.name));
    } finally {
      isSaving.value = false;
    }
  }
}

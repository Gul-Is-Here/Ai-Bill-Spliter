import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/view_state.dart';
import '../../bill/models/bill.dart';
import '../../bill/models/participant.dart';
import '../../bill/repositories/bill_repository.dart';
import '../models/group.dart';
import '../models/settlement.dart';
import '../repositories/group_repository.dart';
import '../services/settlement_calculator.dart';
import 'groups_viewmodel.dart';

class GroupDetailViewModel extends GetxController {
  GroupDetailViewModel(this._groups, this._bills, this._list, Group initial) : group = initial.obs;

  final GroupRepository _groups;
  final BillRepository _bills;
  final GroupsViewModel _list;

  final Rx<Group> group;
  final bills = <Bill>[].obs;
  final state = ViewState.loading.obs;

  /// Net balance per member per currency (positive = is owed).
  final balances = <String, Map<String, int>>{}.obs;
  final suggested = <Settlement>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    bills.assignAll(_bills.cachedBills(groupId: group.value.id));
    _recompute();
    if (bills.isNotEmpty) state.value = ViewState.success;
    bills.assignAll(await _bills.fetchGroupBills(group.value.id));
    _recompute();
    state.value = bills.isEmpty ? ViewState.empty : ViewState.success;
  }

  void _recompute() {
    final b = SettlementCalculator.balances(bills, group.value.settlements);
    balances.assignAll(b);
    suggested.assignAll(SettlementCalculator.minimize(b));
  }

  String nameOf(String id) =>
      group.value.members.firstWhere((m) => m.id == id, orElse: () => Participant(id: id, name: '?')).name;

  Future<void> recordPayment(Settlement s) async {
    HapticFeedback.mediumImpact();
    final payment = Settlement(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      fromId: s.fromId,
      toId: s.toId,
      amountMinor: s.amountMinor,
      currency: s.currency,
      date: DateTime.now(),
    );
    await _update(group.value.copyWith(settlements: [...group.value.settlements, payment]));
  }

  Future<void> addMember(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final id = '${group.value.id}_m${DateTime.now().microsecondsSinceEpoch}';
    await _update(group.value.copyWith(members: [...group.value.members, Participant(id: id, name: trimmed)]));
  }

  Future<void> _update(Group g) async {
    group.value = await _groups.save(g);
    _list.replace(group.value);
    _recompute();
  }

  Future<void> deleteGroup() async {
    await _list.delete(group.value.id);
    Get.back();
  }
}

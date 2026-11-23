import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/view_state.dart';
import '../../bill/models/bill.dart';
import '../../bill/repositories/bill_repository.dart';

class HistoryViewModel extends GetxController {
  HistoryViewModel(this._repository, this._connectivity);

  final BillRepository _repository;
  final ConnectivityService _connectivity;

  final bills = <Bill>[].obs;
  final state = ViewState.loading.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();

  DocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _hasMore = true;
  Worker? _onlineWorker;

  @override
  void onInit() {
    super.onInit();
    _showCached();
    refreshBills();
    _onlineWorker = ever<bool>(_connectivity.isOnline, (online) {
      if (online) _syncAndRefresh();
    });
  }

  void _showCached() {
    bills.assignAll(_repository.cachedBills());
    state.value = bills.isEmpty ? ViewState.loading : ViewState.success;
  }

  Future<void> _syncAndRefresh() async {
    await _repository.syncPendingImages();
    await refreshBills();
  }

  Future<void> refreshBills() async {
    _cursor = null;
    _hasMore = true;
    try {
      final page = await _repository.fetchPage();
      _cursor = page.cursor;
      _hasMore = page.bills.length == BillRepository.pageSize;
      // Merge server page with local bills not yet synced.
      final serverIds = page.bills.map((b) => b.id).toSet();
      final pendingLocal = _repository.cachedBills().where((b) => !serverIds.contains(b.id));
      final merged = [...page.bills, ...pendingLocal.where((b) => !_hasMore || b.date.isAfter(page.bills.last.date))]
        ..sort((x, y) => y.date.compareTo(x.date));
      bills.assignAll(merged);
      state.value = bills.isEmpty ? ViewState.empty : ViewState.success;
    } on AppException catch (e) {
      // Offline: cached data is still valid to show.
      if (bills.isNotEmpty) {
        state.value = ViewState.success;
      } else {
        errorMessage.value = e.message;
        state.value = _connectivity.isOnline.value ? ViewState.failure : ViewState.empty;
      }
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore.value || _cursor == null) return;
    isLoadingMore.value = true;
    try {
      final page = await _repository.fetchPage(after: _cursor);
      _cursor = page.cursor ?? _cursor;
      _hasMore = page.bills.length == BillRepository.pageSize;
      final known = bills.map((b) => b.id).toSet();
      bills.addAll(page.bills.where((b) => !known.contains(b.id)));
    } on AppException {
      // Keep what we have; next scroll retries.
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> delete(Bill bill) async {
    await _repository.delete(bill);
    bills.removeWhere((b) => b.id == bill.id);
    if (bills.isEmpty) state.value = ViewState.empty;
  }

  /// Called when returning from the split flow with a newly saved bill.
  void reloadLocal() {
    final local = _repository.cachedBills();
    final known = {for (final b in local) b.id: b};
    bills.assignAll([
      ...local.where((b) => !bills.any((x) => x.id == b.id)),
      ...bills.map((b) => known[b.id] ?? b),
    ]..sort((x, y) => y.date.compareTo(x.date)));
    state.value = bills.isEmpty ? ViewState.empty : ViewState.success;
  }

  @override
  void onClose() {
    _onlineWorker?.dispose();
    super.onClose();
  }
}

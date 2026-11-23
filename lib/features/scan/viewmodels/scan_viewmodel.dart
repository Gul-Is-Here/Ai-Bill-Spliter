import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/local_cache_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/utils/view_state.dart';
import '../../bill/models/bill.dart';
import '../../groups/repositories/group_repository.dart';
import '../repositories/scan_repository.dart';

class ScanViewModel extends GetxController {
  ScanViewModel(
    this._repository,
    this._permissions,
    this._analytics,
    this._connectivity,
    this._cache,
    this._groups, {
    ImagePicker? picker,
  }) : _picker = picker ?? ImagePicker();

  final ScanRepository _repository;
  final PermissionService _permissions;
  final AnalyticsService _analytics;
  final ConnectivityService _connectivity;
  final LocalCacheService _cache;
  final GroupRepository _groups;
  final ImagePicker _picker;

  final state = ViewState.idle.obs;
  final previewPath = RxnString();
  final errorMessage = RxnString();

  /// Compressed image kept on device so the user can still enter items manually and upload later.
  String? _savedImagePath;
  String? _billId;

  String? get groupId => Get.parameters['groupId'];

  String get _currency => (groupId == null ? null : _groups.cachedGroup(groupId!)?.currency) ?? _cache.defaultCurrency;

  Future<void> scan(ImageSource source) async {
    if (state.value == ViewState.loading) return;
    if (source == ImageSource.camera && !await _permissions.ensure(Permission.camera)) return;

    final picked = await _picker.pickImage(source: source);
    if (picked == null) return;

    previewPath.value = picked.path;
    errorMessage.value = null;
    _savedImagePath = null;
    state.value = ViewState.loading;
    _analytics.log(AnalyticsEvent.scanStarted, {'source': source.name});
    final billId = _billId = _repository.newBillId();

    try {
      final bytes = await _repository.compress(picked.path);
      _savedImagePath = await _persist(billId, bytes);
      if (!_connectivity.isOnline.value) throw const AppException('error_offline_scan');
      final path = await _repository.upload(billId, bytes);
      final bill = await _repository.scan(
        billId: billId,
        receiptPath: path,
        fallbackCurrency: _currency,
      );
      _analytics.log(AnalyticsEvent.scanSuccess, {'items': bill.items.length});
      HapticFeedback.mediumImpact();
      state.value = ViewState.success;
      _openReview(bill.copyWith(localImagePath: _savedImagePath, groupId: groupId));
    } catch (e) {
      final error = AppException.from(e);
      _analytics.log(AnalyticsEvent.scanFailed, {'reason': error.messageKey});
      errorMessage.value = error.message;
      state.value = ViewState.failure;
    }
  }

  /// Manual entry; if a photo was taken, it's attached and uploaded when online.
  void enterManually() {
    _openReview(Bill(
      id: _billId ?? _repository.newBillId(),
      title: '',
      currency: _currency,
      date: DateTime.now(),
      groupId: groupId,
      localImagePath: _savedImagePath,
    ));
  }

  void _openReview(Bill bill) {
    final group = groupId == null ? null : _groups.cachedGroup(groupId!);
    final ready = group == null || bill.participants.isNotEmpty
        ? bill
        : bill.copyWith(participants: group.members, payerId: group.members.firstOrNull?.id);
    Get.offNamed(AppRoutes.reviewItems, arguments: ready);
  }

  Future<String> _persist(String billId, Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/receipt_$billId.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}

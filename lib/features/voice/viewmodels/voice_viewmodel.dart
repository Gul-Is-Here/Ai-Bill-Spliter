import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/permission_service.dart';
import '../models/voice_split_result.dart';
import '../repositories/voice_repository.dart';

enum VoiceStatus { idle, listening, processing, error }

class VoiceViewModel extends GetxController {
  VoiceViewModel(this._repository, this._permissions, this._analytics, this.itemNames);

  final VoiceRepository _repository;
  final PermissionService _permissions;
  final AnalyticsService _analytics;
  final List<String> itemNames;

  final status = VoiceStatus.idle.obs;
  final transcript = ''.obs;
  final errorMessage = RxnString();

  @override
  void onReady() {
    super.onReady();
    start();
  }

  Future<void> start() async {
    errorMessage.value = null;
    if (!await _permissions.ensure(Permission.microphone)) {
      Get.back();
      return;
    }
    final ok = await _repository.init(onStatus: (s) {
      if ((s == 'done' || s == 'notListening') && status.value == VoiceStatus.listening) _finishListening();
    });
    if (!ok) {
      _fail('error_speech_unavailable');
      return;
    }
    transcript.value = '';
    status.value = VoiceStatus.listening;
    HapticFeedback.lightImpact();
    final locale = Get.locale?.languageCode == 'ur' ? 'ur_PK' : 'en_US';
    await _repository.listen(localeId: locale, onResult: (text, isFinal) {
      transcript.value = text;
      if (isFinal) _finishListening();
    });
  }

  Future<void> stopListening() async {
    await _repository.stop();
    await _finishListening();
  }

  Future<void> _finishListening() async {
    if (status.value != VoiceStatus.listening) return;
    if (transcript.value.trim().length < 3) {
      _fail('error_voice_empty');
      return;
    }
    status.value = VoiceStatus.processing;
    try {
      final VoiceSplitResult result = await _repository.parse(transcript.value, itemNames);
      _analytics.log(AnalyticsEvent.voiceSplitUsed, {'method': result.method.name});
      HapticFeedback.mediumImpact();
      Get.back(result: result);
    } on AppException catch (e) {
      _fail(e.messageKey);
    }
  }

  void _fail(String key) {
    errorMessage.value = key.tr;
    status.value = VoiceStatus.error;
  }

  @override
  void onClose() {
    _repository.cancel();
    super.onClose();
  }
}

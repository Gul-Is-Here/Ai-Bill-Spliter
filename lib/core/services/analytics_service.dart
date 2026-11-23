import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

enum AnalyticsEvent { scanStarted, scanSuccess, scanFailed, billSplit, billShared, voiceSplitUsed }

class AnalyticsService extends GetxService {
  final _analytics = FirebaseAnalytics.instance;

  static const _names = {
    AnalyticsEvent.scanStarted: 'scan_started',
    AnalyticsEvent.scanSuccess: 'scan_success',
    AnalyticsEvent.scanFailed: 'scan_failed',
    AnalyticsEvent.billSplit: 'bill_split',
    AnalyticsEvent.billShared: 'bill_shared',
    AnalyticsEvent.voiceSplitUsed: 'voice_split_used',
  };

  Future<void> log(AnalyticsEvent event, [Map<String, Object>? params]) =>
      _analytics.logEvent(name: _names[event]!, parameters: params);
}

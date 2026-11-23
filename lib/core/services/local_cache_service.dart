import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Offline cache. Stores JSON maps so models need no Hive adapters.
class LocalCacheService extends GetxService {
  static const _settingsBox = 'settings';
  static const _cacheBox = 'cache';

  late final Box<dynamic> settings;
  late final Box<dynamic> cache;

  Future<LocalCacheService> init() async {
    settings = await Hive.openBox<dynamic>(_settingsBox);
    cache = await Hive.openBox<dynamic>(_cacheBox);
    return this;
  }

  String get defaultCurrency => settings.get('currency', defaultValue: 'PKR') as String;

  Future<void> clearUserData() => cache.clear();
}

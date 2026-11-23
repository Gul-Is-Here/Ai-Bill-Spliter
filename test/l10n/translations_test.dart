import 'dart:io';

import 'package:ai_bill_spliter/app/translations/en.dart';
import 'package:ai_bill_spliter/app/translations/ur.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Urdu define the same keys', () {
    expect(ur.keys.toSet().difference(en.keys.toSet()), isEmpty, reason: 'keys only in Urdu');
    expect(en.keys.toSet().difference(ur.keys.toSet()), isEmpty, reason: 'keys missing from Urdu');
  });

  test('every literal key used with .tr / .trParams exists', () {
    final usage = RegExp(r"""'([a-z0-9_]+)'\.tr(?:Params)?\b""");
    final missing = <String>{};
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      final src = f.readAsStringSync();
      for (final m in usage.allMatches(src)) {
        if (!en.containsKey(m.group(1))) missing.add('${m.group(1)} (${f.path})');
      }
    }
    // Keys built at runtime.
    for (final t in ['trip', 'home', 'friends', 'other']) {
      if (!en.containsKey('group_type_$t')) missing.add('group_type_$t');
    }
    for (final k in ['app_name', 'groups', 'settings']) {
      if (!en.containsKey(k)) missing.add(k);
    }
    expect(missing, isEmpty);
  });

  test('error keys produced by AppException and SplitCalculator exist', () {
    final src = [
      File('lib/core/errors/app_exception.dart').readAsStringSync(),
      File('lib/features/split/services/split_calculator.dart').readAsStringSync(),
      File('lib/features/split/viewmodels/split_flow_viewmodel.dart').readAsStringSync(),
      File('lib/features/scan/repositories/scan_repository.dart').readAsStringSync(),
      File('lib/features/voice/viewmodels/voice_viewmodel.dart').readAsStringSync(),
    ].join();
    final keys = RegExp(r"'(error_[a-z_]+)'").allMatches(src).map((m) => m.group(1)!).toSet();
    expect(keys.where((k) => !en.containsKey(k)), isEmpty);
  });
}

import 'package:get/get.dart';

import 'en.dart';
import 'ur.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': en, 'ur_PK': ur};
}

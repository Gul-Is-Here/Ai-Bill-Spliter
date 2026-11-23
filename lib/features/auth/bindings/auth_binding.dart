import 'package:get/get.dart';

import '../viewmodels/login_viewmodel.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => LoginViewModel(Get.find()));
}

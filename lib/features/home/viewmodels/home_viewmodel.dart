import 'package:get/get.dart';

class HomeViewModel extends GetxController {
  final tab = 0.obs;

  void selectTab(int index) => tab.value = index;
}

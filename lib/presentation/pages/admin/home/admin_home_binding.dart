import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/admin/home/admin_home_controller.dart';

class AdminHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminHomeController>(() => AdminHomeController());
  }
}

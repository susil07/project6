import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/admin/users/user_management_controller.dart';

class UserManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserManagementController>(() => UserManagementController());
  }
}

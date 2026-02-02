import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/profile/user_profile_controller.dart';

class UserProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserProfileController>(() => UserProfileController());
  }
}

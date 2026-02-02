import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/delivery/profile/delivery_profile_controller.dart';

class DeliveryProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DeliveryProfileController());
  }
}

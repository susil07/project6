import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/delivery/home/delivery_home_controller.dart';

class DeliveryHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryHomeController>(() => DeliveryHomeController());
  }
}

import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/delivery/delivery_controller.dart';

class DeliveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryController>(() => DeliveryController());
  }
}

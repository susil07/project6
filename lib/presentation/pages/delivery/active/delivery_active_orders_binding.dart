import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/delivery/active/delivery_active_orders_controller.dart';

class DeliveryActiveOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryActiveOrdersController>(() => DeliveryActiveOrdersController());
  }
}

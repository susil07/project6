import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/orders/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersController>(() => OrdersController());
  }
}

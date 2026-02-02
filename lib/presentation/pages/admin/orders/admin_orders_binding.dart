import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/admin/orders/admin_orders_controller.dart';

class AdminOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminOrdersController>(() => AdminOrdersController());
  }
}

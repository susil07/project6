import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/orders/tracking/order_tracking_controller.dart';

class OrderTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderTrackingController>(() => OrderTrackingController());
  }
}

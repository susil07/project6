import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/checkout/checkout_controller.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}

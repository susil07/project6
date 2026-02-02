import 'package:get/get.dart';
import 'package:tasty_go/presentation/controllers/cart_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    // Use putIfAbsent to ensure it's a singleton
    Get.put(CartController(), permanent: true);
  }
}

import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/admin/food/admin_food_controller.dart';

class AdminFoodBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminFoodController>(() => AdminFoodController());
  }
}

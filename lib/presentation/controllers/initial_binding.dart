import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/favorites/favorites_controller.dart';
import 'package:tasty_go/presentation/controllers/cart_controller.dart';
import 'package:tasty_go/presentation/controllers/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ThemeController is initialized in main() because it's needed before GetMaterialApp
    Get.put(FavoritesController());
    Get.put(CartController());
  }
}

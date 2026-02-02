import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/favorites/favorites_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesController>(() => FavoritesController());
  }
}

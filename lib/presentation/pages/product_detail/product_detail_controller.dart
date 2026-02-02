import 'package:get/get.dart';
import 'package:tasty_go/data/models/food_item_model.dart';

class ProductDetailController extends GetxController {
  final RxInt quantity = 1.obs;
  late final FoodItemModel product;

  @override
  void onInit() {
    super.onInit();
    product = Get.arguments as FoodItemModel;
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void addToCart() {
    // TODO: Implement cart functionality
    Get.snackbar(
      'Added to Cart',
      '${product.name} x${quantity.value} added to cart',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

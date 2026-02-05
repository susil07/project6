import 'package:get/get.dart';
import 'package:tasty_go/data/models/food_item_model.dart';
import 'package:tasty_go/presentation/controllers/cart_controller.dart';

class ProductDetailController extends GetxController {
  final RxInt quantity = 1.obs;
  late final FoodItemModel product;
  final CartController _cartController = Get.find<CartController>();

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

  Future<void> addToCart() async {
    final double? price = double.tryParse(product.price);
    if (price == null) {
      Get.snackbar('Error', 'Invalid price format');
      return;
    }
    
    await _cartController.addToCartFromModel(
      foodItemModel: product,
      price: price,
      quantity: quantity.value,
    );
  }
}

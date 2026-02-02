import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasty_go/data/models/cart_item_model.dart';
import 'package:tasty_go/data/models/food_item.dart';
import 'package:tasty_go/data/models/food_item_model.dart';
import 'package:tasty_go/data/services/cart_service.dart';

class CartController extends GetxController {
  final CartService _cartService = CartService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var cartItems = <CartItem>[].obs;
  var isLoading = false.obs;

  // Computed values
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  double get tax => subtotal * 0.05; // 5% tax
  
  double get deliveryFee => cartItems.isEmpty ? 0.0 : 50.0; // ₹50 delivery fee
  
  double get total => subtotal + tax + deliveryFee;

  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  void _loadCart() {
    final user = _auth.currentUser;
    if (user != null) {
      // Listen to cart changes in real-time
      _cartService.getCartStream(user.uid).listen((items) {
        cartItems.value = items;
      });
    }
  }

  Future<void> addToCart({
    required FoodItem foodItem,
    required int quantity,
    String? specialInstructions,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'Please login to add items to cart',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isLoading.value = true;

      await _cartService.addToCart(
        userId: user.uid,
        foodItem: foodItem,
        quantity: quantity,
        specialInstructions: specialInstructions,
      );

      Get.snackbar(
        'Added to Cart',
        '${foodItem.name} added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.primary,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add item to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _cartService.updateQuantity(
        userId: user.uid,
        cartItemId: cartItemId,
        quantity: quantity,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update quantity',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeItem(String cartItemId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _cartService.removeFromCart(
        userId: user.uid,
        cartItemId: cartItemId,
      );

      Get.snackbar(
        'Removed',
        'Item removed from cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove item',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> clearCart() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _cartService.clearCart(user.uid);

      Get.snackbar(
        'Cart Cleared',
        'All items removed from cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear cart',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void incrementQuantity(CartItem item) {
    updateQuantity(item.id, item.quantity + 1);
  }

  void decrementQuantity(CartItem item) {
    if (item.quantity > 1) {
      updateQuantity(item.id, item.quantity - 1);
    } else {
      removeItem(item.id);
    }
  }

  // Helper method to add from FoodItemModel
  Future<void> addToCartFromModel({
    required FoodItemModel foodItemModel,
    required double price,
    required int quantity,
    String? specialInstructions,
  }) async {
    // Create simple food item for cart
    final foodItem = FoodItem(
      id: foodItemModel.id,
      name: foodItemModel.name,
      price: price,
      imageUrl: foodItemModel.imageUrl,
    );
    
    await addToCart(
      foodItem: foodItem,
      quantity: quantity,
      specialInstructions: specialInstructions,
    );
  }
}

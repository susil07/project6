import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:tasty_go/data/services/order_service.dart';
import 'package:tasty_go/presentation/controllers/cart_controller.dart';

class CheckoutController extends GetxController {
  final OrderService _orderService = OrderService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CartController cartController = Get.find<CartController>();

  // Form controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();

  // Payment method
  var selectedPaymentMethod = 'cod'.obs; // 'cod' or 'online'

  var isPlacingOrder = false.obs;

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    pincodeController.dispose();
    super.onClose();
  }

  bool validateForm() {
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter full name');
      return false;
    }
    if (phoneController.text.trim().isEmpty || phoneController.text.length < 10) {
      Get.snackbar('Error', 'Please enter valid phone number');
      return false;
    }
    if (addressLine1Controller.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter address');
      return false;
    }
    if (cityController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter city');
      return false;
    }
    if (pincodeController.text.trim().isEmpty || pincodeController.text.length != 6) {
      Get.snackbar('Error', 'Please enter valid pincode');
      return false;
    }
    return true;
  }

  Future<void> placeOrder() async {
    if (!validateForm()) return;

    if (cartController.cartItems.isEmpty) {
      Get.snackbar('Error', 'Your cart is empty');
      return;
    }

    try {
      isPlacingOrder.value = true;

      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'Please login to place order');
        return;
      }

      // Build delivery address string
      final deliveryAddress = [
        fullNameController.text.trim(),
        phoneController.text.trim(),
        addressLine1Controller.text.trim(),
        if (addressLine2Controller.text.trim().isNotEmpty) addressLine2Controller.text.trim(),
        cityController.text.trim(),
        pincodeController.text.trim(),
      ].join(', ');

      // Convert cart items to order items
      final orderItems = cartController.cartItems.map((cartItem) {
        return OrderItem(
          foodId: cartItem.foodId,
          name: cartItem.name,
          price: cartItem.price,
          quantity: cartItem.quantity,
          imageUrl: cartItem.imageUrl,
        );
      }).toList();

      // Create order
      final order = FoodOrder(
        id: '', // Will be set by Firestore
        userId: user.uid,
        items: orderItems,
        deliveryAddress: deliveryAddress,
        paymentMethod: selectedPaymentMethod.value == 'cod' ? 'Cash on Delivery' : 'Online Payment',
        subtotal: cartController.subtotal,
        tax: cartController.tax,
        deliveryFee: cartController.deliveryFee,
        total: cartController.total,
        createdAt: DateTime.now(),
      );

      // Save order to Firestore
      final orderId = await _orderService.createOrder(order);

      // Clear cart
      await cartController.clearCart();

      // Navigate to confirmation page
      Get.offAllNamed('/order-confirmation', arguments: orderId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to place order: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
    } finally {
      isPlacingOrder.value = false;
    }
  }
}

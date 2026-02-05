import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:tasty_go/data/models/address_model.dart';
import 'package:tasty_go/data/services/order_service.dart';
import 'package:tasty_go/data/services/address_service.dart';
import 'package:tasty_go/presentation/controllers/cart_controller.dart';

class CheckoutController extends GetxController {
  final OrderService _orderService = OrderService();
  final AddressService _addressService = AddressService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CartController cartController = Get.find<CartController>();

  // Addresses
  var addresses = <AddressModel>[].obs;
  var selectedAddress = Rxn<AddressModel>();
  var isLoadingAddresses = true.obs;

  // Payment method
  var selectedPaymentMethod = 'cod'.obs; // 'cod' or 'online'
  var isPlacingOrder = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAddresses();
  }

  void _loadAddresses() {
    final user = _auth.currentUser;
    if (user != null) {
      // Bind stream to addresses list
      addresses.bindStream(_addressService.getAddressesStream(user.uid));
      
      // Listen to addresses to auto-select default
      ever(addresses, (List<AddressModel> list) {
        isLoadingAddresses.value = false;
        if (selectedAddress.value == null && list.isNotEmpty) {
          // Select default or first
          final defaultAddr = list.firstWhereOrNull((a) => a.isDefault);
          selectedAddress.value = defaultAddr ?? list.first;
        }
      });
    }
  }

  Future<void> placeOrder() async {
    if (cartController.cartItems.isEmpty) {
      Get.snackbar('Error', 'Your cart is empty');
      return;
    }

    if (selectedAddress.value == null) {
      Get.snackbar('Error', 'Please select a delivery address');
      return;
    }

    try {
      isPlacingOrder.value = true;
      final user = _auth.currentUser;
      
      if (user == null) {
        Get.snackbar('Error', 'Please login to place order');
        return;
      }

      final addr = selectedAddress.value!;
      
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

      // Fetch restaurant settings
      final restaurantDoc = await FirebaseFirestore.instance.collection('settings').doc('restaurant').get();
      final restaurantData = restaurantDoc.data();

      // Create order
      final order = FoodOrder(
        id: '', // Will be set by Firestore
        userId: user.uid,
        items: orderItems,
        deliveryAddress: '${addr.fullAddress}, ${addr.city} - ${addr.pincode}, Ph: ${addr.phone}',
        deliveryLatitude: addr.latitude != 0.0 ? addr.latitude : null,
        deliveryLongitude: addr.longitude != 0.0 ? addr.longitude : null,
        restaurantLatitude: (restaurantData?['latitude'] as num?)?.toDouble() ?? 17.448293, // Default Madhapur
        restaurantLongitude: (restaurantData?['longitude'] as num?)?.toDouble() ?? 78.392485,
        restaurantName: restaurantData?['name'] as String? ?? 'Tasty Go - Madhapur',
        restaurantAddress: restaurantData?['address'] as String? ?? 'Madhapur, Hyderabad',
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

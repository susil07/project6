import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:tasty_go/data/services/delivery_service.dart';

class DeliveryActiveOrdersController extends GetxController {
  final DeliveryService _deliveryService = DeliveryService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var activeOrders = <FoodOrder>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadActiveOrders();
  }

  void _loadActiveOrders() {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    _deliveryService.getAssignedOrders(user.uid).listen(
      (orders) {
        // Filter out delivered and cancelled orders
        activeOrders.value = orders.where((o) => 
          o.status != 'delivered' && o.status != 'cancelled'
        ).toList();
        isLoading.value = false;
      },
      onError: (e) {
        print('Error loading active orders: $e');
        isLoading.value = false;
      },
    );
  }

  Future<void> updateStatus(String orderId, String status) async {
    try {
      await _deliveryService.updateOrderStatus(orderId, status);
      Get.snackbar('Success', 'Order status updated to $status');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e');
    }
  }
}

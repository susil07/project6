import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:tasty_go/data/services/delivery_service.dart';

class DeliveryHistoryController extends GetxController {
  final DeliveryService _deliveryService = DeliveryService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var historyOrders = <FoodOrder>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }

  void _loadHistory() {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    _deliveryService.getAssignedOrders(user.uid).listen(
      (orders) {
        // Filter for delivered and cancelled orders
        historyOrders.value = orders.where((o) => 
          o.status == 'delivered' || o.status == 'cancelled'
        ).toList();
        isLoading.value = false;
      },
      onError: (e) {
        print('Error loading history: $e');
        isLoading.value = false;
      },
    );
  }
}

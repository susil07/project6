import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:tasty_go/data/services/firestore_service.dart';

class AdminOrdersController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  
  var orders = <FoodOrder>[].obs;
  var isLoading = true.obs;
  var selectedStatus = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadOrders();
  }

  void _loadOrders() {
    isLoading.value = true;
    _firestoreService.orders.orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      orders.value = snapshot.docs.map((doc) => FoodOrder.fromJson(doc.id, doc.data() as Map<String, dynamic>)).toList();
      isLoading.value = false;
    }, onError: (e) {
      print('Error loading orders: $e');
      isLoading.value = false;
    });
  }

  List<FoodOrder> get filteredOrders {
    if (selectedStatus.value == 'All') return orders;
    return orders.where((o) => o.status == selectedStatus.value).toList();
  }

  Future<void> updateStatus(String orderId, String status) async {
    try {
      await _firestoreService.orders.doc(orderId).update({
        'status': status,
        if (status == 'delivered') 'deliveredAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Success', 'Order status updated to $status');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e');
    }
  }
}

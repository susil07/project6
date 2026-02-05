import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  var totalUsers = 0.obs;
  var pendingUsers = 0.obs;
  var activeOrders = 0.obs;
  var totalOrders = 0.obs;
  var totalFoodItems = 0.obs;
  var recentOrders = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Get total users
      final usersSnapshot = await _firestore.collection('users').get();
      totalUsers.value = usersSnapshot.docs.length;

      // Get pending users
      final pendingSnapshot = await _firestore
          .collection('users')
          .where('status', isEqualTo: 'pending')
          .get();
      pendingUsers.value = pendingSnapshot.docs.length;

      // Get active orders
      final activeOrdersSnapshot = await _firestore
          .collection('orders')
          .where('status', whereIn: ['placed', 'confirmed', 'preparing', 'out_for_delivery'])
          .get();
      activeOrders.value = activeOrdersSnapshot.docs.length;

      // Get total orders
      final totalOrdersSnapshot = await _firestore.collection('orders').get();
      totalOrders.value = totalOrdersSnapshot.docs.length;

      // Get total food items
      final foodSnapshot = await _firestore.collection('food_items').get();
      totalFoodItems.value = foodSnapshot.docs.length;

      // Get recent orders
      final recentOrdersSnapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      
      recentOrders.value = recentOrdersSnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<void> seedRestaurantData() async {
    try {
      await _firestore.collection('settings').doc('restaurant').set({
        'name': 'Tasty Go - Madhapur',
        'address': 'Madhapur, Hyderabad, Telangana',
        'latitude': 17.448293,
        'longitude': 78.392485,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Success', 'Restaurant location set to Hyderabad/Madhapur');
    } catch (e) {
      Get.snackbar('Error', 'Failed to seed restaurant data: $e');
    }
  }

  void refreshStats() {
    _loadStats();
  }
}

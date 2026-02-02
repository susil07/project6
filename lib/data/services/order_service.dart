import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_go/data/models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new order
  Future<String> createOrder(FoodOrder order) async {
    try {
      final docRef = await _firestore.collection('orders').add(order.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  // Get user's orders (real-time stream)
  Stream<List<FoodOrder>> getOrdersStream(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodOrder.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  // Get user's orders (one-time)
  Future<List<FoodOrder>> getOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FoodOrder.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error getting orders: $e');
      return [];
    }
  }

  // Get single order by ID
  Future<FoodOrder?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      
      if (!doc.exists) {
        return null;
      }

      return FoodOrder.fromJson(doc.id, doc.data()!);
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        if (status == 'delivered') 'deliveredAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
      });
    } catch (e) {
      print('Error cancelling order: $e');
      rethrow;
    }
  }
}

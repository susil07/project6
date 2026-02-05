import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_go/data/models/order_model.dart';

class DeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get orders assigned to a specific delivery partner
  Stream<List<FoodOrder>> getAssignedOrders(String partnerId) {
    return _firestore
        .collection('orders')
        .where('deliveryPartnerId', isEqualTo: partnerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodOrder.fromJson(doc.id, doc.data()))
            .toList());
  }

  // Get orders available for pickup (status: confirmed or preparing)
  // In a real app, this might be filtered by region.
  Stream<List<FoodOrder>> getAvailableOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['pending', 'confirmed', 'preparing'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodOrder.fromJson(doc.id, doc.data()))
            .where((order) => order.deliveryPartnerId == null)
            .toList());
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    final Map<String, dynamic> data = {'status': status};
    if (status == 'delivered') {
      data['deliveredAt'] = FieldValue.serverTimestamp();
    }
    await _firestore.collection('orders').doc(orderId).update(data);
  }

  // Assign delivery partner to order
  Future<void> acceptOrder(String orderId, String partnerId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'deliveryPartnerId': partnerId,
      'status': 'preparing', // Or keep as is, but partner assigned
    });
  }

  // Update partner location
  Future<void> updateLocation(String orderId, double lat, double lng) async {
    await _firestore.collection('orders').doc(orderId).update({
      'deliveryPartnerLocation': {
        'latitude': lat,
        'longitude': lng,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    });
  }
}

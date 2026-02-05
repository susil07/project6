import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_go/data/models/cart_item_model.dart';
import 'package:tasty_go/data/models/food_item.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user's cart collection reference
  CollectionReference _getCartCollection(String userId) {
    return _firestore.collection('carts').doc(userId).collection('items');
  }

  // Add item to cart
  Future<void> addToCart({
    required String userId,
    required FoodItem foodItem,
    required int quantity,
    String? specialInstructions,
  }) async {
    try {
      // Check if item already exists in cart
      final existingItems = await _getCartCollection(userId)
          .where('foodId', isEqualTo: foodItem.id)
          .get();

      if (existingItems.docs.isNotEmpty) {
        // Item exists - update quantity and timestamp
        final doc = existingItems.docs.first;
        final data = doc.data() as Map<String, dynamic>?;
        final currentQuantity = (data?['quantity'] as int?) ?? 0;
        await doc.reference.update({
          'quantity': currentQuantity + quantity,
          'addedAt': FieldValue.serverTimestamp(), // Update timestamp to bring to top
        });
      } else {
        // Add new item
        await _getCartCollection(userId).add({
          'foodId': foodItem.id,
          'name': foodItem.name,
          'price': foodItem.price,
          'imageUrl': foodItem.imageUrl,
          'quantity': quantity,
          if (specialInstructions != null) 'specialInstructions': specialInstructions,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  // Update item quantity
  Future<void> updateQuantity({
    required String userId,
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        // Remove item if quantity is 0 or negative
        await removeFromCart(userId: userId, cartItemId: cartItemId);
      } else {
        await _getCartCollection(userId).doc(cartItemId).update({
          'quantity': quantity,
        });
      }
    } catch (e) {
      print('Error updating quantity: $e');
      rethrow;
    }
  }

  // Remove item from cart
  Future<void> removeFromCart({
    required String userId,
    required String cartItemId,
  }) async {
    try {
      await _getCartCollection(userId).doc(cartItemId).delete();
    } catch (e) {
      print('Error removing from cart: $e');
      rethrow;
    }
  }

  // Get cart items stream (real-time)
  Stream<List<CartItem>> getCartStream(String userId) {
    return _getCartCollection(userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CartItem.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get cart items (one-time)
  Future<List<CartItem>> getCart(String userId) async {
    try {
      final snapshot = await _getCartCollection(userId)
          .orderBy('addedAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => CartItem.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting cart: $e');
      return [];
    }
  }

  // Clear entire cart
  Future<void> clearCart(String userId) async {
    try {
      final snapshot = await _getCartCollection(userId).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
    }
  }

  // Get cart total
  Future<double> getCartTotal(String userId) async {
    try {
      final items = await getCart(userId);
      return items.fold<double>(0.0, (total, item) => total + item.totalPrice);
    } catch (e) {
      print('Error calculating cart total: $e');
      return 0.0;
    }
  }

  // Get cart item count
  Future<int> getCartItemCount(String userId) async {
    try {
      final items = await getCart(userId);
      return items.fold<int>(0, (total, item) => total + item.quantity);
    } catch (e) {
      print('Error getting cart count: $e');
      return 0;
    }
  }
}

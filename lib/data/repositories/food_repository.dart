import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_go/data/models/food_item_model.dart';
import 'package:tasty_go/data/services/firestore_service.dart';

class FoodRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // Get all food items
  Stream<List<FoodItemModel>> getAllFoodItems() {
    return _firestoreService.foodItems
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodItemModel.fromFirestore(doc))
            .toList());
  }

  // Get food items by IDs
  Stream<List<FoodItemModel>> getFoodItemsByIds(List<String> ids) {
    if (ids.isEmpty) return Stream.value([]);
    return _firestoreService.foodItems
        .where(FieldPath.documentId, whereIn: ids.take(10).toList())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodItemModel.fromFirestore(doc))
            .toList());
  }

  // Get food items by category
  Stream<List<FoodItemModel>> getFoodItemsByCategory(String category) {
    return _firestoreService.foodItems
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodItemModel.fromFirestore(doc))
            .toList());
  }

  // Search food items
  Stream<List<FoodItemModel>> searchFoodItems(String query) {
    // Note: Firestore doesn't support full-text search natively
    // For production, consider using Algolia or ElasticSearch
    // This is a simple name-based search
    return _firestoreService.foodItems.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => FoodItemModel.fromFirestore(doc))
          .toList();
      
      if (query.isEmpty) return items;
      
      return items
          .where((item) =>
              item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Get food item by ID
  Future<FoodItemModel?> getFoodItemById(String id) async {
    final doc = await _firestoreService.foodItems.doc(id).get();
    if (doc.exists) {
      return FoodItemModel.fromFirestore(doc);
    }
    return null;
  }

  // Add new food item (admin function)
  Future<void> addFoodItem(FoodItemModel item) async {
    await _firestoreService.foodItems.doc(item.id).set(item.toJson());
  }

  // Update food item (admin function)
  Future<void> updateFoodItem(FoodItemModel item) async {
    await _firestoreService.foodItems.doc(item.id).update(item.toJson());
  }

  // Delete food item (admin function)
  Future<void> deleteFoodItem(String id) async {
    await _firestoreService.foodItems.doc(id).delete();
  }
}

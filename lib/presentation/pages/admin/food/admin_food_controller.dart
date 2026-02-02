import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_go/data/models/food_item_model.dart';
import 'package:tasty_go/data/services/firestore_service.dart';

class AdminFoodController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  
  var foodItems = <FoodItemModel>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;
  var selectedCategory = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFoodItems();
  }

  void _loadFoodItems() {
    isLoading.value = true;
    _firestoreService.foodItems.orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      foodItems.value = snapshot.docs.map((doc) => FoodItemModel.fromFirestore(doc)).toList();
      isLoading.value = false;
    }, onError: (e) {
      print('Error loading food items: $e');
      isLoading.value = false;
    });
  }

  List<FoodItemModel> get filteredFoodItems {
    return foodItems.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesCategory = selectedCategory.value == 'All' || item.category == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> addFoodItem(FoodItemModel item) async {
    try {
      await _firestoreService.foodItems.add(item.toJson());
      Get.snackbar('Success', 'Food item added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add food item: $e');
    }
  }

  Future<void> updateFoodItem(FoodItemModel item) async {
    try {
      await _firestoreService.foodItems.doc(item.id).update(item.toJson());
      Get.snackbar('Success', 'Food item updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update food item: $e');
    }
  }

  Future<void> deleteFoodItem(String id) async {
    try {
      await _firestoreService.foodItems.doc(id).delete();
      Get.snackbar('Success', 'Food item deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete food item: $e');
    }
  }
}

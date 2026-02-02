import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_go/data/models/food_item_model.dart';
import 'package:tasty_go/data/repositories/food_repository.dart';
import 'package:tasty_go/data/services/auth_service.dart';

class FavoritesController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FoodRepository _foodRepository = FoodRepository();
  final AuthService _authService = AuthService();

  final RxList<String> favoriteIds = <String>[].obs;
  final RxList<FoodItemModel> favoriteItems = <FoodItemModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToFavorites();
  }

  void _listenToFavorites() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore.collection('users').doc(user.uid).snapshots().listen((doc) {
      if (doc.exists) {
        final List<String> ids = List<String>.from(doc.data()?['favorites'] ?? []);
        favoriteIds.value = ids;
        _loadFavoriteItems(ids);
      }
    });
  }

  void _loadFavoriteItems(List<String> ids) {
    if (ids.isEmpty) {
      favoriteItems.clear();
      return;
    }

    _foodRepository.getFoodItemsByIds(ids).listen((items) {
      favoriteItems.value = items;
    });
  }

  Future<void> toggleFavorite(String productId) async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Please login to add favorites');
      return;
    }

    final isFavorite = favoriteIds.contains(productId);
    try {
      await _authService.toggleFavorite(user.uid, productId, !isFavorite);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update favorites: $e');
    }
  }

  bool isFavorite(String productId) {
    return favoriteIds.contains(productId);
  }
}

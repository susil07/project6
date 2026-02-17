import 'dart:async';
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

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _favoritesSubscription;

  @override
  void onInit() {
    super.onInit();
    print('🟣 [FAVORITES] Controller initialized');
    // Listen to auth state changes
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        print('🟣 [FAVORITES] Auth state changed: User logged in (${user.uid})');
        _listenToFavorites(user);
      } else {
        print('🟣 [FAVORITES] Auth state changed: User logged out');
        _clearFavorites();
      }
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _favoritesSubscription?.cancel();
    super.onClose();
  }

  void _listenToFavorites(User user) {
    // Cancel existing subscription if any
    _favoritesSubscription?.cancel();
    
    print('🟣 [FAVORITES] Listening to favorites for user: ${user.uid}');

    _favoritesSubscription = _firestore.collection('users').doc(user.uid).snapshots().listen((doc) {
      if (doc.exists) {
        final List<String> ids = List<String>.from(doc.data()?['favorites'] ?? []);
        print('🟢 [FAVORITES] Received favorites from Firestore: $ids');
        favoriteIds.value = ids;
        _loadFavoriteItems(ids);
      } else {
        print('🟡 [FAVORITES] User document does not exist');
        favoriteIds.clear();
        favoriteItems.clear();
      }
    }, onError: (e) {
      print('🔴 [FAVORITES] Error listening to favorites: $e');
    });
  }

  void _clearFavorites() {
    _favoritesSubscription?.cancel();
    favoriteIds.clear();
    favoriteItems.clear();
  }

  void _loadFavoriteItems(List<String> ids) {
    if (ids.isEmpty) {
      favoriteItems.clear();
      return;
    }

    _foodRepository.getFoodItemsByIds(ids).listen((items) {
      print('🟢 [FAVORITES] Loaded ${items.length} food items');
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
    print('🔵 [FAVORITES] Toggling favorite for $productId. Current state: $isFavorite');
    
    try {
      await _authService.toggleFavorite(user.uid, productId, !isFavorite);
      print('🟢 [FAVORITES] Toggle successful');
    } catch (e) {
      print('🔴 [FAVORITES] Toggle failed: $e');
      Get.snackbar('Error', 'Failed to update favorites: $e');
    }
  }

  bool isFavorite(String productId) {
    return favoriteIds.contains(productId);
  }
}

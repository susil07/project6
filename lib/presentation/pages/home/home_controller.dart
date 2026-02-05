import 'package:get/get.dart';
import 'package:tasty_go/data/models/food_item_model.dart';
import 'package:tasty_go/data/repositories/food_repository.dart';
import 'package:tasty_go/data/services/firestore_seeder.dart';
import 'package:tasty_go/data/services/address_service.dart';
import 'package:tasty_go/data/models/address_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeController extends GetxController {
  final RxInt selectedBottomIndex = 0.obs;
  final RxString selectedCategory = 'Foods'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isSeeding = false.obs;
  final RxList<FoodItemModel> allFoodItems = <FoodItemModel>[].obs;

  final List<String> categories = ['Foods', 'Drinks', 'Snacks', 'Sauces'];
  final FoodRepository _foodRepository = FoodRepository();
  final FirestoreSeeder _seeder = FirestoreSeeder();
  final AddressService _addressService = AddressService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rxn<AddressModel> currentAddress = Rxn<AddressModel>();

  @override
  void onInit() {
    super.onInit();
    _listenToFoodItems();
    _listenToAddress();
  }

  void _listenToAddress() {
    final user = _auth.currentUser;
    if (user != null) {
      _addressService.getAddressesStream(user.uid).listen((addresses) {
        if (addresses.isNotEmpty) {
          // Find default or first
          currentAddress.value = addresses.firstWhereOrNull((a) => a.isDefault) ?? addresses.first;
        } else {
          currentAddress.value = null;
        }
      });
    }
  }

  // Listen to Firestore real-time updates
  void _listenToFoodItems() {
    isLoading.value = true;
    
    _foodRepository.getAllFoodItems().listen(
      (items) {
        allFoodItems.value = items;
        isLoading.value = false;
      },
      onError: (error) {
        print('Error loading food items: $error');
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Failed to load food items. Using offline data.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  // Seed sample data
  Future<void> seedSampleData() async {
    try {
      isSeeding.value = true;
      
      // Check if data already exists
      final exists = await _seeder.checkIfDataExists();
      if (exists) {
        Get.snackbar(
          'Info',
          'Food items already exist in database!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      await _seeder.seedFoodItems();
      
      Get.snackbar(
        'Success',
        '10 food items added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.primary,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to seed data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
    } finally {
      isSeeding.value = false;
    }
  }

  List<FoodItemModel> get filteredItems {
    var items = allFoodItems.where((item) {
      final matchesCategory = item.category == selectedCategory.value;
      return matchesCategory;
    }).toList();

    if (searchQuery.value.isNotEmpty) {
      items = items
          .where((item) =>
              item.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    return items;
  }

  void onBottomNavChanged(int index) {
    selectedBottomIndex.value = index;
  }

  void onCategoryChanged(String category) {
    selectedCategory.value = category;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void logout() {
    Get.offAllNamed('/welcome');
  }
}

import 'package:get/get.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:tasty_go/data/services/order_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasty_go/presentation/controllers/cart_controller.dart';
import 'package:tasty_go/data/models/food_item_model.dart';

class OrdersController extends GetxController {
  final OrderService _orderService = OrderService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Filter state
  var currentFilter = 'all'.obs; // all, active, completed
  
  // Orders
  var allOrders = <FoodOrder>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadOrders();
  }

  void _loadOrders() {
    final user = _auth.currentUser;
    if (user != null) {
      isLoading.value = true;
      _orderService.getOrdersStream(user.uid).listen((orders) {
        allOrders.value = orders;
        isLoading.value = false;
      }, onError: (e) {
        print('Error loading orders: $e');
        isLoading.value = false;
      });
    }
  }

  void setFilter(String filter) {
    currentFilter.value = filter;
  }

  List<FoodOrder> get filteredOrders {
    if (currentFilter.value == 'all') {
      return allOrders;
    } else if (currentFilter.value == 'active') {
      return allOrders.where((o) => !o.isDelivered && !o.isCancelled).toList();
    } else {
      return allOrders.where((o) => o.isDelivered || o.isCancelled).toList();
    }
  }

  void reorder(FoodOrder order) {
    final cartController = Get.find<CartController>();
    for (var item in order.items) {
      // Mocking a FoodItemModel from OrderItem for reorder
      final foodItem = FoodItemModel(
        id: item.foodId,
        name: item.name,
        price: '₹${item.price.toInt()}',
        imageUrl: item.imageUrl,
        category: '', // Logic doesn't strictly need this for cart
        description: '',
        createdAt: DateTime.now(),
      );
      
      cartController.addToCartFromModel(
        foodItemModel: foodItem,
        price: item.price,
        quantity: item.quantity,
      );
    }
    Get.snackbar(
      'Reordered',
      'Items from order added to cart',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

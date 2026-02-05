import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:tasty_go/data/services/delivery_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tasty_go/data/services/location_service.dart';

class DeliveryHomeController extends GetxController {
  final DeliveryService _deliveryService = DeliveryService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Active orders assigned to this partner
  var assignedOrders = <FoodOrder>[].obs;
  // Orders available for everyone to pick up
  var availableOrders = <FoodOrder>[].obs;
  
  var isLoading = true.obs;
  var isLocationStreaming = false.obs;
  
  StreamSubscription? _assignedSub;
  StreamSubscription? _availableSub;

  @override
  void onInit() {
    super.onInit();
    _loadOrders();
  }

  @override
  void onClose() {
    _assignedSub?.cancel();
    _availableSub?.cancel();
    LocationService.stopTracking(); // Ensure tracking stops when closed
    super.onClose();
  }

  void _loadOrders() {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;

    // Stream assigned orders
    _assignedSub = _deliveryService.getAssignedOrders(user.uid).listen(
      (orders) {
        assignedOrders.value = orders;
        isLoading.value = false;
        
        // If any order is out_for_delivery, start background location service
        final hasActiveDelivery = orders.any((o) => o.status == 'out_for_delivery');
        if (hasActiveDelivery && !isLocationStreaming.value) {
          _startLocationTracking(user.uid);
        } else if (!hasActiveDelivery && isLocationStreaming.value) {
          _stopLocationTracking();
        }
      },
      onError: (e) {
        print('🔴 [DELIVERY_HOME] Assigned orders error: $e');
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Failed to load assigned orders. You might need to create a Firestore index.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 10),
        );
      },
    );

    // Stream available orders
    _availableSub = _deliveryService.getAvailableOrders().listen(
      (orders) {
        availableOrders.value = orders;
      },
      onError: (e) {
        print('🔴 [DELIVERY_HOME] Available orders error: $e');
      },
    );
  }

  Future<void> acceptOrder(String orderId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _deliveryService.acceptOrder(orderId, user.uid);
      Get.snackbar('Success', 'Order accepted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept order: $e');
    }
  }

  Future<void> updateStatus(String orderId, String status) async {
    try {
      await _deliveryService.updateOrderStatus(orderId, status);
      Get.snackbar('Status Updated', 'Order is now $status');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e');
    }
  }

  void _startLocationTracking(String partnerId) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Location Disabled', 'Please enable location services');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Permission Denied', 'Location permission is permanently denied. Please enable it in settings.');
      return;
    }

    // Background tracking works best with Always permission
    if (permission == LocationPermission.whileInUse) {
       // Request Always permission for background updates
       permission = await Geolocator.requestPermission();
    }

    isLocationStreaming.value = true;
    await LocationService.startTracking(partnerId);
  }

  void _stopLocationTracking() async {
    await LocationService.stopTracking();
    isLocationStreaming.value = false;
  }
}

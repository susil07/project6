import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:tasty_go/data/services/delivery_service.dart';
import 'package:geolocator/geolocator.dart';

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
  StreamSubscription? _locationSub;

  @override
  void onInit() {
    super.onInit();
    _loadOrders();
  }

  @override
  void onClose() {
    _assignedSub?.cancel();
    _availableSub?.cancel();
    _locationSub?.cancel();
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
        
        // If any order is out_for_delivery, start location stream
        final hasActiveDelivery = orders.any((o) => o.status == 'out_for_delivery');
        if (hasActiveDelivery && !isLocationStreaming.value) {
          _startLocationStreaming();
        } else if (!hasActiveDelivery && isLocationStreaming.value) {
          _stopLocationStreaming();
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
        // If index is missing, available orders also won't load
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

  void _startLocationStreaming() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    isLocationStreaming.value = true;
    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      // Update location for all active out_for_delivery orders
      for (var order in assignedOrders.where((o) => o.status == 'out_for_delivery')) {
        _deliveryService.updateLocation(
          order.id,
          position.latitude,
          position.longitude,
        );
      }
    });
  }

  void _stopLocationStreaming() {
    _locationSub?.cancel();
    isLocationStreaming.value = false;
  }
}

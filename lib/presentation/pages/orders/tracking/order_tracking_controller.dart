import 'dart:async';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderTrackingController extends GetxController {
  final String orderId = Get.parameters['orderId'] ?? '';

  var currentOrder = Rxn<FoodOrder>();
  var isMapLoading = true.obs;
  
  // Maps
  GoogleMapController? mapController;
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;
  
  StreamSubscription? _orderSubscription;
  Timer? _simulationTimer;

  // Mock Route (Bangalore)
  final List<LatLng> _mockRoute = [
    const LatLng(12.9716, 77.5946), // MG Road
    const LatLng(12.9700, 77.5900),
    const LatLng(12.9680, 77.5880),
    const LatLng(12.9650, 77.5850),
    const LatLng(12.9600, 77.5800), // Destination
  ];
  int _simulationIndex = 0;

  @override
  void onInit() {
    super.onInit();
    _loadOrder();
  }

  @override
  void onClose() {
    _orderSubscription?.cancel();
    _simulationTimer?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    print('DEBUG: Map Created Successfully');
    mapController = controller;
    isMapLoading.value = false;
    _updateMapBounds();
  }

  void _loadOrder() {
    print('DEBUG: Loading Order with ID: $orderId');
    // Listen to order updates
    _orderSubscription = FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        print('DEBUG: Order data received: ${snapshot.data()}');
        final order = FoodOrder.fromJson(snapshot.id, snapshot.data()!);
        currentOrder.value = order;
        _updateMapMarkers(order);
        
        // Start simulation if out for delivery
        if (order.status == 'out_for_delivery' && _simulationTimer == null) {
          print('DEBUG: Starting simulation as status is out_for_delivery');
          _startSimulation();
        }
      } else {
        print('DEBUG: Order does not exist in Firestore');
      }
    }, onError: (error) {
      print('DEBUG: Firestore Error: $error');
    });
  }

  void _updateMapMarkers(FoodOrder order) {
    markers.clear();
    
    // Delivery Partner Marker (use mock or actual)
    LatLng partnerLoc = _mockRoute[_simulationIndex];
    if (order.deliveryPartnerLocation != null) {
      partnerLoc = LatLng(
        order.deliveryPartnerLocation!.latitude,
        order.deliveryPartnerLocation!.longitude,
      );
    }

    markers.add(
      Marker(
        markerId: const MarkerId('delivery_partner'),
        position: partnerLoc,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Delivery Partner'),
      ),
    );

    // Customer Marker (Destination - Mock for now, would be order.deliveryAddress geocoded)
    const customerLoc = LatLng(12.9600, 77.5800);
    markers.add(
      Marker(
        markerId: const MarkerId('customer'),
        position: customerLoc,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'You'),
      ),
    );

    // Polyline
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: _mockRoute,
        color: Get.theme.colorScheme.primary,
        width: 5,
      ),
    );

    _updateMapBounds();
  }

  void _updateMapBounds() {
    if (mapController == null || markers.isEmpty) return;

    LatLngBounds bounds;
    // Simple bounds logic for demo
    bounds = LatLngBounds(
      southwest: const LatLng(12.9600, 77.5800),
      northeast: const LatLng(12.9716, 77.5946),
    );

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  // Simulator for Demo purposes
  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_simulationIndex < _mockRoute.length - 1) {
        _simulationIndex++;
        
        // Update Firestore with new location (simulation)
        final loc = _mockRoute[_simulationIndex];
        FirebaseFirestore.instance.collection('orders').doc(orderId).update({
          'deliveryPartnerLocation': {
            'latitude': loc.latitude,
            'longitude': loc.longitude,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          'estimatedDeliveryMinutes': (5 - _simulationIndex).toDouble(), // Fake ETA
        });
      } else {
        // Delivered
        timer.cancel();
        FirebaseFirestore.instance.collection('orders').doc(orderId).update({
          'status': 'delivered',
          'deliveredAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}

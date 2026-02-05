import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class OrderTrackingController extends GetxController {
  final String orderId = Get.parameters['orderId'] ?? '';

  var currentOrder = Rxn<FoodOrder>();
  var isMapLoading = true.obs;
  
  // Maps
  GoogleMapController? mapController;
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;
  
  StreamSubscription? _orderSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadOrder();
  }

  @override
  void onClose() {
    _orderSubscription?.cancel();
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
      } else {
        print('DEBUG: Order does not exist in Firestore');
      }
    }, onError: (error) {
      print('DEBUG: Firestore Error: $error');
    });
  }

  void _updateMapMarkers(FoodOrder order) {
    markers.clear();
    
    // Delivery Partner Marker
    LatLng? partnerLoc;
    if (order.deliveryPartnerLocation != null) {
      partnerLoc = LatLng(
        order.deliveryPartnerLocation!.latitude,
        order.deliveryPartnerLocation!.longitude,
      );

      markers.add(
        Marker(
          markerId: const MarkerId('delivery_partner'),
          position: partnerLoc,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(title: 'Delivery Partner', snippet: 'On the way'),
        ),
      );
    }

    // Restaurant Marker (Source)
    LatLng? restaurantLoc;
    if (order.restaurantLatitude != null && order.restaurantLongitude != null) {
      restaurantLoc = LatLng(order.restaurantLatitude!, order.restaurantLongitude!);
      markers.add(
        Marker(
          markerId: const MarkerId('restaurant'),
          position: restaurantLoc,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: const InfoWindow(title: 'Restaurant', snippet: 'Preparing your food'),
        ),
      );
    }

    // Customer Marker (Destination)
    LatLng? customerLoc;
    if (order.deliveryLatitude != null && order.deliveryLongitude != null) {
      customerLoc = LatLng(order.deliveryLatitude!, order.deliveryLongitude!);
      markers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: customerLoc,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'You', snippet: 'Delivery Location'),
        ),
      );
    }

    // Polylines Logic
    polylines.clear();
    
    if (order.status == 'out_for_delivery') {
      // Path: Partner -> Customer (Active)
      if (partnerLoc != null && customerLoc != null) {
        polylines.add(Polyline(
          polylineId: const PolylineId('partner_to_customer'),
          points: [partnerLoc, customerLoc],
          color: Colors.blue,
          width: 5,
        ));
      }
    } else if (['preparing', 'confirmed'].contains(order.status)) {
      // Path 1: Partner -> Restaurant (if assigned)
      if (partnerLoc != null && restaurantLoc != null) {
        polylines.add(Polyline(
          polylineId: const PolylineId('partner_to_restaurant'),
          points: [partnerLoc, restaurantLoc],
          color: Colors.orange,
          width: 4,
          patterns: [PatternItem.dash(10), PatternItem.gap(10)],
        ));
      }
      // Path 2: Restaurant -> Customer (Future)
      if (restaurantLoc != null && customerLoc != null) {
        polylines.add(Polyline(
          polylineId: const PolylineId('restaurant_to_customer'),
          points: [restaurantLoc, customerLoc],
          color: Colors.grey,
          width: 4,
        ));
      }
    } else {
      // Pending/Default: Restaurant -> Customer
      if (restaurantLoc != null && customerLoc != null) {
        polylines.add(Polyline(
          polylineId: const PolylineId('restaurant_to_customer'),
          points: [restaurantLoc, customerLoc],
          color: Colors.grey,
          width: 4,
        ));
      }
    }

    _updateMapBounds();
    _calculateETA(order);
  }

  void _updateMapBounds() {
    if (mapController == null || markers.isEmpty) return;

    LatLng? restaurantPos;
    LatLng? partnerPos;
    
    for (var m in markers) {
      if (m.markerId.value == 'restaurant') restaurantPos = m.position;
      if (m.markerId.value == 'delivery_partner') partnerPos = m.position;
    }

    final status = currentOrder.value?.status;

    // 1. Partner Tracking Focus (Accepted or Out for delivery)
    if (partnerPos != null && (status == 'out_for_delivery' || status == 'preparing')) {
      mapController!.animateCamera(CameraUpdate.newLatLngZoom(partnerPos, 16));
      return;
    }

    // 2. Restaurant Focus (Initial / Waiting for Partner)
    if (restaurantPos != null && (status == 'pending' || status == 'confirmed')) {
      mapController!.animateCamera(CameraUpdate.newLatLngZoom(restaurantPos, 16));
      return;
    }

    // 3. Fallback: Fit all markers
    if (markers.isEmpty) return;
    
    // ... existing bounds logic if needed, or just default to first marker
    if (markers.isNotEmpty) {
       // Just fit bounds as fallback
       double minLat = markers.first.position.latitude;
       double maxLat = markers.first.position.latitude;
       double minLng = markers.first.position.longitude;
       double maxLng = markers.first.position.longitude;

      for (var m in markers) {
        if (m.position.latitude < minLat) minLat = m.position.latitude;
        if (m.position.latitude > maxLat) maxLat = m.position.latitude;
        if (m.position.longitude < minLng) minLng = m.position.longitude;
        if (m.position.longitude > maxLng) maxLng = m.position.longitude;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
      
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  void _calculateETA(FoodOrder order) {
    if (order.isDelivered || order.isCancelled) return;

    double? startLat, startLng;
    double? endLat, endLng;

    // Define Destination (Customer)
    if (order.deliveryLatitude != null && order.deliveryLongitude != null) {
      endLat = order.deliveryLatitude;
      endLng = order.deliveryLongitude;
    }

    // Define Source based on Status
    if (order.status == 'out_for_delivery') {
      // From Partner
      if (order.deliveryPartnerLocation != null) {
        startLat = order.deliveryPartnerLocation!.latitude;
        startLng = order.deliveryPartnerLocation!.longitude;
      }
    } else {
      // From Restaurant
      if (order.restaurantLatitude != null && order.restaurantLongitude != null) {
        startLat = order.restaurantLatitude;
        startLng = order.restaurantLongitude;
      }
    }

    if (startLat != null && startLng != null && endLat != null && endLng != null) {
      final distanceInMeters = Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
      
      // Avg Speed in City: 25 km/h = ~416 meters/minute
      double speedMetersPerMin = 400; 
      
      double travelTime = distanceInMeters / speedMetersPerMin;
      
      // Add buffer for prep time
      if (order.status == 'preparing') travelTime += 15;
      if (order.status == 'pending') travelTime += 20;
      if (order.status == 'confirmed') travelTime += 15;

      // Update local state with calculated ETA
      if (travelTime != order.estimatedDeliveryMinutes) {
        // Create a new updated order object to trigger UI
        final updatedOrder = FoodOrder(
          id: order.id,
          userId: order.userId,
          items: order.items,
          deliveryAddress: order.deliveryAddress,
          deliveryLatitude: order.deliveryLatitude,
          deliveryLongitude: order.deliveryLongitude,
          restaurantLatitude: order.restaurantLatitude,
          restaurantLongitude: order.restaurantLongitude,
          restaurantName: order.restaurantName,
          restaurantAddress: order.restaurantAddress,
          paymentMethod: order.paymentMethod,
          subtotal: order.subtotal,
          tax: order.tax,
          deliveryFee: order.deliveryFee,
          total: order.total,
          status: order.status,
          createdAt: order.createdAt,
          deliveredAt: order.deliveredAt,
          deliveryPartnerId: order.deliveryPartnerId,
          deliveryPartnerLocation: order.deliveryPartnerLocation,
          estimatedDeliveryMinutes: travelTime, // Updated ETA
        );
        currentOrder.value = updatedOrder;
      }
    }
  }
}

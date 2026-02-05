import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tasty_go/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static const String _serviceActionStart = "setAsForeground";
  static const String _serviceActionStop = "setAsBackground";
  static const String _serviceActionStopService = "stopService";

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'location_tracking',
        initialNotificationTitle: 'Delivery Tracking Active',
        initialNotificationContent: 'Updating your location for active deliveries',
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  static Future<void> startTracking(String partnerId) async {
    // Request notification permission for Android 13+
    var status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    if (status.isPermanentlyDenied) {
      print('🔴 [LOCATION_SERVICE] Notification permission permanently denied. Cannot start service.');
      return;
    }

    if (!status.isGranted) {
       print('🔴 [LOCATION_SERVICE] Notification permission not granted. Cannot start service.');
       return;
    }

    // Initialize service now that we have permissions
    await initializeService();

    final storage = GetStorage();
    await storage.write('partnerId', partnerId);
    
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    if (!isRunning) {
      await service.startService();
    }
  }

  static Future<void> stopTracking() async {
    final service = FlutterBackgroundService();
    service.invoke(_serviceActionStopService);
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase in background isolate
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final storage = GetStorage();
  final String? partnerId = storage.read('partnerId');

  if (partnerId == null) {
    service.stopSelf();
    return;
  }

  service.on("stopService").listen((event) {
    service.stopSelf();
  });

  // Update location periodically
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        try {
          service.setForegroundNotificationInfo(
            title: "Delivery Tracking Active",
            content: "Updating location at ${DateTime.now().hour}:${DateTime.now().minute}",
          );
        } catch (e) {
          print('⚠️ [LOCATION_SERVICE] Failed to update notification: $e');
        }
      }
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Find active "out_for_delivery" orders for this partner
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('deliveryPartnerId', isEqualTo: partnerId)
          .where('status', isEqualTo: 'out_for_delivery')
          .get();

      for (var doc in ordersSnapshot.docs) {
        await doc.reference.update({
          'deliveryPartnerLocation': {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        });
      }
      
      print('📍 [LOCATION_SERVICE] Updated location for ${ordersSnapshot.docs.length} orders');
    } catch (e) {
      print('📍 [LOCATION_SERVICE] Error: $e');
    }
  });
}

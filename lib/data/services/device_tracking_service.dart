import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceTrackingService {
  static final DeviceTrackingService _instance = DeviceTrackingService._internal();
  factory DeviceTrackingService() => _instance;
  DeviceTrackingService._internal();

  final _storage = GetStorage();
  final _firestore = FirebaseFirestore.instance;
  final _deviceInfo = DeviceInfoPlugin();

  Future<void> init() async {
    try {
      String uuid = _storage.read('device_uuid') ?? '';
      if (uuid.isEmpty) {
        uuid = const Uuid().v4();
        await _storage.write('device_uuid', uuid);
      }

      final Map<String, dynamic> deviceData = await _getDeviceData();
      
      await _firestore.collection('device_tracking').doc(uuid).set({
        ...deviceData,
        'uuid': uuid,
        'last_seen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // User merge: true to avoid overwriting existing fields if any

      if (kDebugMode) {
        print('✅ Device tracked: $uuid (${deviceData['platform']})');
      }
    } catch (e) {
      print('⚠️ Failed to track device: $e');
    }
  }

  Future<Map<String, dynamic>> _getDeviceData() async {
    String platform = 'Unknown';
    String model = 'Unknown';

    try {
      if (kIsWeb) {
        platform = 'Web';
        final WebBrowserInfo webInfo = await _deviceInfo.webBrowserInfo;
        model = webInfo.userAgent ?? 'Unknown Web Browser';
      } else if (Platform.isAndroid) {
        platform = 'Android';
        final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        model = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        platform = 'iOS';
        final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        model = '${iosInfo.name} ${iosInfo.model}';
      } else if (Platform.isMacOS) {
         platform = 'MacOS';
         final MacOsDeviceInfo macInfo = await _deviceInfo.macOsInfo;
         model = macInfo.model;
      }
      // Add other platforms if needed
    } catch (e) {
      print('⚠️ Error getting device info: $e');
    }

    return {
      'platform': platform,
      'model': model,
    };
  }
}

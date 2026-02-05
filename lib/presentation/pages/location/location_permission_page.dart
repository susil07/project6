import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tasty_go/presentation/pages/profile/address/address_management_page.dart';

class LocationPermissionPage extends StatelessWidget {
  const LocationPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 100.sp,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: 32.h),
            Text(
              'Location Required',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'We need your location to show you nearby restaurants and deliver your food accurately.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            SizedBox(height: 48.h),
            
            // Enable Location Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () => _checkAndRequestLocation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('Enable Location'),
              ),
            ),
            SizedBox(height: 16.h),
            
            // Manual Address Entry
            TextButton(
              onPressed: () => Get.to(() => const AddressManagementPage()),
              child: Text(
                'Enter Address Manually',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAndRequestLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check service
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Permission Denied', 'Location permission is denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission Denied', 
        'Location permissions are permanently denied, we cannot request permissions.',
      );
      await Geolocator.openAppSettings();
      return;
    }

    // Success
    Get.offAllNamed('/home');
  }
}

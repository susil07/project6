import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tasty_go/presentation/navigation/app_routes.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  var statusMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  void _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is already logged in
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      // No user logged in - go to welcome
      print('🔵 [SPLASH] No user logged in - navigating to welcome');
      Get.offNamed(Routes.welcome);
      return;
    }

    print('🔵 [SPLASH] User logged in: ${currentUser.email}');
    statusMessage.value = 'Verifying user...';
    print('   Fetching user data from Firestore...');

    try {
      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        print('🔴 [SPLASH] User document not found - navigating to welcome');
        await _auth.signOut();
        Get.offNamed(Routes.welcome);
        return;
      }

      final userData = userDoc.data()!;
      final role = userData['role'] ?? 'user';
      var status = userData['status'];

      // Backward compatibility for admin users
      if (status == null && role == 'admin') {
        print('🟡 [SPLASH] No status for admin - auto-approving');
        status = 'approved';
        await _firestore.collection('users').doc(currentUser.uid).update({
          'status': status,
        });
      }

      print('🟢 [SPLASH] User data fetched');
      print('   Role: $role');
      print('   Status: $status');

      // Route based on role and status
      if (role == 'admin') {
        // Admins can skip location check
        print('🔵 [SPLASH] Admin user - navigating to admin dashboard');
        Get.offNamed(Routes.adminHome);
      } else if (role == 'delivery_partner') {
        // Delivery partners strictly need location
        statusMessage.value = 'Checking location...';
        _checkLocationAndNavigate(Routes.deliveryHome);
      } else {
        // Check status for users
        if (status == 'pending') {
          print('🟡 [SPLASH] Pending user - navigating to pending approval');
          Get.offNamed(Routes.pendingApproval);
        } else if (status == 'rejected' || status == 'blocked') {
          print('🔴 [SPLASH] Rejected/blocked user - logging out');
          await _auth.signOut();
          Get.offNamed(Routes.welcome);
          Get.snackbar(
            'Account ${status == 'rejected' ? 'Rejected' : 'Blocked'}',
            'Your account has been ${status}. ${userData['statusNote'] ?? ''}',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          // Approved user - check location
          print('🔵 [SPLASH] Approved user - checking location before home');
          statusMessage.value = 'Fetching your current location...';
          _checkLocationAndNavigate(Routes.home);
        }
      }
    } catch (e) {
      print('🔴 [SPLASH] Error fetching user data: $e');
      await _auth.signOut();
      Get.offNamed(Routes.welcome);
    }
  }

  Future<void> _checkLocationAndNavigate(String targetRoute) async {
    // We import geolocator dynamically to avoid import issues if not used elsewhere in file
    // Note: Ideally import it at top. Assuming imports are added.
    try {
      final isLoggedIn = _auth.currentUser != null;
      if (!isLoggedIn) {
         Get.offNamed(Routes.welcome);
         return;
      }
      
      // Artificial delay to let user see "Fetching location..."
      await Future.delayed(const Duration(milliseconds: 800));

      // Simple check for enabled service and permissions
      // We don't request here, just check state. If bad, go to LocationPage.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.offNamed(Routes.locationPermission);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        Get.offNamed(Routes.locationPermission);
        return;
      }

      // All good
      Get.offNamed(targetRoute);
    } catch (e) {
      print('Error checking location: $e');
      // If error (e.g. platform issue), default to home but maybe show warning?
      // Or safer to go to location page if we are strict.
      Get.offNamed(Routes.locationPermission);
    }
  }
}

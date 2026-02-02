import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_go/presentation/navigation/app_routes.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        // Admins always go to admin dashboard
        print('🔵 [SPLASH] Admin user - navigating to admin dashboard');
        Get.offNamed(Routes.adminHome);
      } else {
        // Check status for non-admin users
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
        } else if (role == 'delivery_partner') {
          print('🔵 [SPLASH] Delivery Partner - navigating to dashboard');
          Get.offNamed(Routes.deliveryHome);
        } else {
          // Approved user
          print('🔵 [SPLASH] Approved user - navigating to home');
          Get.offNamed(Routes.home);
        }
      }
    } catch (e) {
      print('🔴 [SPLASH] Error fetching user data: $e');
      await _auth.signOut();
      Get.offNamed(Routes.welcome);
    }
  }
}

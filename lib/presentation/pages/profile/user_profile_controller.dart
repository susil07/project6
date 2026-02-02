import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_go/presentation/pages/auth/auth_controller.dart';

class UserProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  var isLoading = true.obs;
  var userData = <String, dynamic>{}.obs;
  var totalOrders = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }
  
  Future<void> _loadUserProfile() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        // Load user details
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          userData.value = userDoc.data() ?? {};
        }
        
        // Load some stats
        final ordersSnapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .get();
        totalOrders.value = ordersSnapshot.docs.length;
      }
    } catch (e) {
      print('Error loading user profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void logout() {
    Get.find<AuthController>().logout();
  }

  Future<void> updateProfile({required String displayName}) async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        // Update Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': displayName,
        });
        
        // Update local state
        userData['displayName'] = displayName;
        userData.refresh();
        
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void refreshProfile() {
    _loadUserProfile();
  }
}

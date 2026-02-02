import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var userData = <String, dynamic>{}.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        userData.value = doc.data()!;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

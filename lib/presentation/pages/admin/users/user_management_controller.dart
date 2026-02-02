import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasty_go/data/models/user_model.dart';

class UserManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  var users = <UserModel>[].obs;
  var filteredUsers = <UserModel>[].obs;
  var isLoading = true.obs;
  var selectedFilter = 'all'.obs; // all, pending, approved, blocked

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
  }

  void _loadUsers() {
    isLoading.value = true;
    
    _firestore.collection('users').snapshots().listen((snapshot) {
      users.value = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
      
      _applyFilter();
      isLoading.value = false;
    });
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  void _applyFilter() {
    if (selectedFilter.value == 'all') {
      filteredUsers.value = users;
    } else {
      filteredUsers.value = users
          .where((user) => user.status == selectedFilter.value)
          .toList();
    }
  }

  Future<void> approveUser(String userId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      
      await _firestore.collection('users').doc(userId).update({
        'status': 'approved',
        'approvedBy': currentUserId,
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'User approved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.primary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to approve user: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
    }
  }

  Future<void> rejectUser(String userId, String reason) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'rejected',
        'statusNote': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'User rejected',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reject user: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
    }
  }

  Future<void> blockUser(String userId, String reason) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'blocked',
        'statusNote': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'User blocked',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
    }catch (e) {
      Get.snackbar(
        'Error',
        'Failed to block user: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'approved',
        'statusNote': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'User unblocked',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.primary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to unblock user: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
    }
  }
}

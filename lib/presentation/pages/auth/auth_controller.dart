import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_go/data/services/auth_service.dart';
import 'package:tasty_go/presentation/navigation/app_routes.dart';

enum UserRole { user, deliveryPartner, admin }

class AuthController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  
  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();

  var isLogin = true.obs;
  var isLoading = false.obs;
  var selectedRole = UserRole.user.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
  }

  void toggleAuthMode() {
    isLogin.value = !isLogin.value;
  }

  void selectRole(UserRole role) {
    selectedRole.value = role;
  }

  String getRoleString(UserRole role) {
    switch (role) {
      case UserRole.user:
        return 'user';
      case UserRole.deliveryPartner:
        return 'delivery_partner';
      case UserRole.admin:
        return 'admin';
    }
  }

  Future<void> login() async {
    print('🔵 [AUTH] Login started');
    
    // Validation
    if (loginEmailController.text.isEmpty || loginPasswordController.text.isEmpty) {
      print('🔴 [AUTH] Validation failed - empty fields');
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromRGBO(255, 0, 0, 0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;
      print('🔵 [AUTH] Loading state set to true');
      
      print('🔵 [AUTH] Calling Firebase signInWithEmail...');
      print('   Email: ${loginEmailController.text.trim()}');
      
      final credential = await _authService.signInWithEmail(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text,
      );

      print('🟢 [AUTH] Firebase login successful');
      print('   User ID: ${credential?.user?.uid}');
      print('   Email: ${credential?.user?.email}');

      if (credential?.user != null) {
        // Fetch user role and status from Firestore
        print('🔵 [AUTH] Fetching user data from Firestore...');
        
        final userDoc = await _firestore
            .collection('users')
            .doc(credential!.user!.uid)
            .get();
        
        if (!userDoc.exists) {
          print('🔴 [AUTH] User document does not exist - creating one');
          // Create user document for existing Firebase auth users
          await _firestore.collection('users').doc(credential.user!.uid).set({
            'uid': credential.user!.uid,
            'email': credential.user!.email ?? '',
            'displayName': credential.user!.displayName ?? '',
            'role': 'user',
            'status': 'approved', // Existing users auto-approved
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          final role = 'user';
          final status = 'approved';
          
          print('🟢 [AUTH] User document created');
          print('   Role: $role');
          print('   Status: $status');
          
          _navigateBasedOnRole(role);
          Get.snackbar(
            'Success',
            'Welcome back! (Role: $role)',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.1),
            colorText: Colors.green,
          );
          return;
        }
        
        final userData = userDoc.data()!;
        var role = userData['role'] ?? 'user';
        var status = userData['status'];
        
        // Backward compatibility: If status is null, set it based on role
        if (status == null) {
          print('🟡 [AUTH] User has no status field - migrating user...');
          // Admin users created before the approval system should be auto-approved
          status = (role == 'admin') ? 'approved' : 'pending';
          
          // Update user document with status
          await _firestore.collection('users').doc(credential.user!.uid).update({
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
          print('🟢 [AUTH] User migrated with status: $status');
        }
        
        print('🟢 [AUTH] User data fetched successfully');
        print('   Role: $role');
        print('   Status: $status');
        print('   User document data: $userData');
        
        // Admin users bypass approval status
        if (role == 'admin') {
          print('🟢 [AUTH] Admin user - bypassing status check');
          _navigateBasedOnRole(role);
          Get.snackbar(
            'Success',
            'Welcome back, Admin!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.1),
            colorText: Colors.green,
          );
          print('🟢 [AUTH] Login completed successfully');
          return;
        }
        
        // Check approval status for non-admin users
        if (status == 'pending') {
          print('🟡 [AUTH] User status is pending - navigating to pending screen');
          Get.offAllNamed('/pending-approval');
          Get.snackbar(
            'Pending Approval',
            'Your account is awaiting admin approval.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withValues(alpha: 0.1),
            colorText: Colors.orange,
          );
          return;
        } else if (status == 'rejected') {
          print('🔴 [AUTH] User status is rejected');
          await _authService.signOut();
          Get.snackbar(
            'Account Rejected',
            'Your account has been rejected. Reason: ${userData['statusNote'] ?? 'Not specified'}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.1),
            colorText: Colors.red,
            duration: const Duration(seconds: 5),
          );
          return;
        } else if (status == 'blocked') {
          print('🔴 [AUTH] User status is blocked');
          await _authService.signOut();
          Get.snackbar(
            'Account Blocked',
            'Your account has been blocked. Reason: ${userData['statusNote'] ?? 'Not specified'}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.1),
            colorText: Colors.red,
            duration: const Duration(seconds: 5),
          );
          return;
        }
        
        // User is approved - navigate based on role
        print('🔵 [AUTH] User approved - navigating based on role: $role');
        _navigateBasedOnRole(role);
        
        Get.snackbar(
          'Success',
          'Welcome back! (Role: $role)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green,
        );
        
        print('🟢 [AUTH] Login completed successfully');
      } else {
        print('🔴 [AUTH] Credential user is null');
      }
    } catch (e, stackTrace) {
      print('🔴 [AUTH] Login failed with error:');
      print('   Error: $e');
      print('   Type: ${e.runtimeType}');
      print('   StackTrace: $stackTrace');
      
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromRGBO(255, 0, 0, 0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
      print('🔵 [AUTH] Loading state set to false');
    }
  }

  Future<void> signup() async {
    print('🔵 [AUTH] Signup started');
    
    // Validation
    if (signupNameController.text.isEmpty ||
        signupEmailController.text.isEmpty ||
        signupPasswordController.text.isEmpty) {
      print('🔴 [AUTH] Validation failed - empty fields');
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromRGBO(255, 0, 0, 0.1),
        colorText: Colors.red,
      );
      return;
    }

    if (signupPasswordController.text.length < 6) {
      print('🔴 [AUTH] Validation failed - password too short');
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromRGBO(255, 0, 0, 0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;
      print('🔵 [AUTH] Loading state set to true');
      
      print('🔵 [AUTH] Calling Firebase signUpWithEmail...');
      print('   Email: ${signupEmailController.text.trim()}');
      print('   Name: ${signupNameController.text.trim()}');
      print('   Role: ${getRoleString(selectedRole.value)}');
      
      final credential = await _authService.signUpWithEmail(
        email: signupEmailController.text.trim(),
        password: signupPasswordController.text,
        displayName: signupNameController.text.trim(),
      );

      print('🟢 [AUTH] Firebase signup successful');
      print('   User ID: ${credential?.user?.uid}');
      print('   Email: ${credential?.user?.email}');

      if (credential?.user != null) {
        // Update user document with role (status is already 'pending' from AuthService)
        print('🔵 [AUTH] Updating user document with role...');
        
        await _firestore.collection('users').doc(credential!.user!.uid).update({
          'role': getRoleString(selectedRole.value),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('🟢 [AUTH] User document updated successfully');
        print('   Role: ${getRoleString(selectedRole.value)}');
        print('   Status: pending (awaiting admin approval)');

        // Show success message about pending approval
        Get.snackbar(
          'Account Created',
          'Your account is pending admin approval. You will be notified once approved.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          colorText: Colors.orange,
          duration: const Duration(seconds: 5),
        );
        
        // Navigate to pending approval screen
        print('🔵 [AUTH] Navigating to pending approval screen...');
        Get.offAllNamed('/pending-approval');
        
        print('🟢 [AUTH] Signup completed successfully');
      } else {
        print('🔴 [AUTH] Credential user is null');
      }
    } catch (e, stackTrace) {
      print('🔴 [AUTH] Signup failed with error:');
      print('   Error: $e');
      print('   Type: ${e.runtimeType}');
      print('   StackTrace: $stackTrace');
      
      Get.snackbar(
        'Signup Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromRGBO(255, 0, 0, 0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
      print('🔵 [AUTH] Loading state set to false');
    }
  }

  void _navigateBasedOnRole(String role) {
    switch (role) {
      case 'admin':
        Get.offAllNamed(Routes.adminHome);
        break;
      case 'delivery_partner':
        Get.offAllNamed(Routes.deliveryHome);
        break;
      case 'user':
      default:
        Get.offAllNamed(Routes.home);
        break;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      Get.offAllNamed(Routes.welcome);
      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Logout Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    super.onClose();
  }
}

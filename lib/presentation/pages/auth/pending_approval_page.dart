import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/data/services/auth_service.dart';

class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Icon(
                  Icons.pending_outlined,
                  size: 120.sp,
                  color: Colors.orange,
                ),
                SizedBox(height: 32.h),
                
                // Title
                Text(
                  'Account Pending Approval',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                
                // Description
                Text(
                  'Your account has been created successfully and is currently pending admin approval.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                
                Text(
                  'You will be notified once your account is reviewed. This usually takes 24-48 hours.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.h),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await AuthService().signOut();
                      Get.offAllNamed('/welcome');
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Contact Support (optional)
                TextButton(
                  onPressed: () {
                    Get.snackbar(
                      'Contact Support',
                      'Email: support@tastygo.com',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: Text(
                    'Need help? Contact Support',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

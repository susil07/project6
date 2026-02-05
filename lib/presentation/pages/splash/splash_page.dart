import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/core/constants/app_colors.dart';
import 'package:tasty_go/presentation/pages/splash/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150.w,
              height: 150.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  size: 80.sp,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'TastyGo',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 36.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() {
              if (controller.statusMessage.value.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                   SizedBox(
                    width: 20.w, 
                    height: 20.w, 
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    )
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    controller.statusMessage.value,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

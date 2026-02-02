import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/welcome/welcome_controller.dart';

class WelcomePage extends GetView<WelcomeController> {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check for desktop/web width
            if (constraints.maxWidth > 800) {
              return _buildWebLayout(context, theme);
            }
            return _buildMobileLayout(context, theme);
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogo(theme),
            SizedBox(height: 31.h),
            _buildTitle(),
            SizedBox(height: 40.h),
            _buildIllustration(250.sp),
            SizedBox(height: 40.h),
            _buildGetStartedButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Left Side: Content
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 100.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(theme),
                SizedBox(height: 50.h),
                _buildTitle(),
                SizedBox(height: 60.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300.w),
                  child: _buildGetStartedButton(theme),
                ),
              ],
            ),
          ),
        ),
        // Right Side: Illustration
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.white.withValues(alpha: 0.1),
            child: Center(
              child: _buildIllustration(400.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Container(
      width: 73.w,
      height: 73.w,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 40.sp,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Food for\nEveryone',
      style: TextStyle(
        color: Colors.white,
        fontSize: 65.sp,
        fontWeight: FontWeight.w900,
        height: 0.9,
      ),
    );
  }

  Widget _buildIllustration(double size) {
    return Center(
      child: Icon(
        Icons.delivery_dining,
        size: size,
        color: const Color.fromRGBO(255, 255, 255, 0.8),
      ),
    );
  }

  Widget _buildGetStartedButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 70.h,
      child: ElevatedButton(
        onPressed: controller.onGetStarted,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Get Started',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

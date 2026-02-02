import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/auth/auth_controller.dart';

class AuthPage extends GetView<AuthController> {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildWebLayout(context, theme);
          }
          return _buildMobileLayout(context, theme);
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: TabBarView(
            controller: controller.tabController,
            children: [
              _buildLoginTab(context),
              _buildSignupTab(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebLayout(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Left Side: Branding/Illustration
        Expanded(
          flex: 1,
          child: Container(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150.w,
                  height: 150.w,
                  decoration: const BoxDecoration(
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
                SizedBox(height: 40.h),
                Text(
                  'TastyGo',
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Delivering happiness to your doorstep',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right Side: Auth Form
        Expanded(
          flex: 1,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    controller: controller.tabController,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.secondary,
                    indicatorColor: theme.colorScheme.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(text: 'Login'),
                      Tab(text: 'Sign-up'),
                    ],
                  ),
                  SizedBox(
                    height: 500.h,
                    child: TabBarView(
                      controller: controller.tabController,
                      children: [
                        _buildLoginTab(context),
                        _buildSignupTab(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 60.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.restaurant,
                size: 60.sp,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          TabBar(
            controller: controller.tabController,
            labelColor: theme.colorScheme.onSurface,
            unselectedLabelColor: theme.colorScheme.secondary,
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Login'),
              Tab(text: 'Sign-up'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            context: context,
            label: 'Email address',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            controller: controller.loginEmailController,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 24.h),
          _buildTextField(
            context: context,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            controller: controller.loginPasswordController,
            isPassword: true,
          ),
          SizedBox(height: 15.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Forgot passcode?',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 40.h),
          Obx(() => _buildButton(
            context: context,
            text: controller.isLoading.value ? 'Logging in...' : 'Login',
            onPressed: controller.isLoading.value ? () {} : controller.login,
          )),
        ],
      ),
    );
  }

  Widget _buildSignupTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            context: context,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: Icons.person_outline,
            controller: controller.signupNameController,
          ),
          SizedBox(height: 24.h),
          _buildTextField(
            context: context,
            label: 'Email address',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            controller: controller.signupEmailController,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 24.h),
          _buildTextField(
            context: context,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            controller: controller.signupPasswordController,
            isPassword: true,
          ),
          SizedBox(height: 24.h),
          Text(
            'Select Role',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() => _buildRoleSelector(context)),
          SizedBox(height: 40.h),
          Obx(() => _buildButton(
            context: context,
            text: controller.isLoading.value ? 'Creating Account...' : 'Sign-up',
            onPressed: controller.isLoading.value ? () {} : controller.signup,
          )),
        ],
      ),
    );
  }

  Widget _buildRoleSelector(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildRoleCard(
            context: context,
            role: UserRole.user,
            icon: Icons.person,
            label: 'User',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildRoleCard(
            context: context,
            role: UserRole.deliveryPartner,
            icon: Icons.delivery_dining,
            label: 'Delivery',
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required UserRole role,
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isSelected = controller.selectedRole.value == role;
    
    return GestureDetector(
      onTap: () => controller.selectRole(role),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              size: 28.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.secondary.withValues(alpha: 0.5),
              fontSize: 15.sp,
            ),
            prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: theme.colorScheme.secondary.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: theme.colorScheme.secondary.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({required BuildContext context, required String text, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 60.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

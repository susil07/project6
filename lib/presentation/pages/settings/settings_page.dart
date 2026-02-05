import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/controllers/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSectionHeader(theme, 'Appearance'),
          SizedBox(height: 8.h),
          Obx(() => _buildSwitchTile(
                theme,
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark themes',
                icon: Icons.dark_mode_outlined,
                value: themeController.isDarkMode,
                onChanged: (value) => themeController.switchTheme(),
              )),
          
          SizedBox(height: 24.h),
          _buildSectionHeader(theme, 'Notifications'),
          SizedBox(height: 8.h),
          _buildSwitchTile(
            theme,
            title: 'Push Notifications',
            subtitle: 'Receive updates about your orders',
            icon: Icons.notifications_outlined,
            value: true, // Placeholder
            onChanged: (val) {},
          ),
          
          SizedBox(height: 24.h),
          _buildSectionHeader(theme, 'About'),
          SizedBox(height: 8.h),
          _buildListTile(
            theme,
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            onTap: () {},
          ),
          _buildListTile(
            theme,
            title: 'Terms of Service',
            icon: Icons.description_outlined,
            onTap: () {},
          ),
          _buildListTile(
            theme,
            title: 'App Version',
            subtitle: '1.0.0',
            icon: Icons.info_outline,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme, {
    required String title,
    String? subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title, 
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
        ),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12.sp)) : null,
        secondary: Icon(icon, color: theme.colorScheme.primary),
        activeColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  Widget _buildListTile(
    ThemeData theme, {
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
        ),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12.sp)) : null,
        trailing: Icon(Icons.chevron_right, size: 20.sp, color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}

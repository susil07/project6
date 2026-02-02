import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/admin/admin_controller.dart';
import 'package:tasty_go/presentation/controllers/theme_controller.dart';

class AdminLayout extends GetView<AdminController> {
  final Widget child;
  final String? title;
  
  const AdminLayout({super.key, required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1200;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme, isDesktop),
      drawer: isDesktop ? null : _buildDrawer(theme),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(theme),
          Expanded(child: child),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDesktop) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title ?? 'Admin Dashboard',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      actions: [
        // Notifications
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.onSurface),
          onPressed: () {},
        ),
        SizedBox(width: 8.w),
        // Profile
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    return Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
          SizedBox(height: 24.h),
          // Logo/Brand
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: theme.colorScheme.primary,
                  size: 32.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'TastyGo Admin',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          // Navigation Items
          Expanded(
            child: Obx(() => ListView(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              children: [
                _buildNavItem(
                  theme,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/admin',
                  isActive: controller.currentRoute.value == '/admin',
                ),
                _buildNavItem(
                  theme,
                  icon: Icons.people,
                  label: 'User Management',
                  route: '/admin/users',
                  isActive: controller.currentRoute.value == '/admin/users',
                ),
                _buildNavItem(
                  theme,
                  icon: Icons.restaurant_menu,
                  label: 'Food Items',
                  route: '/admin/food',
                  isActive: controller.currentRoute.value == '/admin/food',
                ),
                _buildNavItem(
                  theme,
                  icon: Icons.receipt_long,
                  label: 'Orders',
                  route: '/admin/orders',
                  isActive: controller.currentRoute.value == '/admin/orders',
                ),
              ],
            )),
          ),
          _buildThemeToggle(theme),
          // Logout
          Padding(
            padding: EdgeInsets.all(12.w),
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: controller.logout,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    ),
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      child: _buildSidebar(theme),
    );
  }

  Widget _buildThemeToggle(ThemeData theme) {
    final themeController = Get.find<ThemeController>();
    return Obx(() => ListTile(
      leading: Icon(
        themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: themeController.isDarkMode ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: const Text('Dark Mode'),
      trailing: Switch(
        value: themeController.isDarkMode,
        onChanged: (val) => themeController.switchTheme(),
      ),
    ));
  }

  Widget _buildNavItem(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isActive,
        selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        onTap: () {
          Get.toNamed(route);
          controller.setCurrentRoute(route);
        },
      ),
    );
  }
}

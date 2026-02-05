import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/profile/user_profile_controller.dart';
import 'package:tasty_go/presentation/pages/home/home_controller.dart';
import 'package:tasty_go/presentation/pages/settings/settings_page.dart';

class UserProfilePage extends GetView<UserProfileController> {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeController = Get.find<HomeController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = controller.userData;

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 40.r),
        child: Column(
          children: [
            // Profile Header
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60.r,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.person, size: 60.r, color: theme.colorScheme.primary),
                ),
                GestureDetector(
                  onTap: () => _showEditProfileDialog(context, data['displayName'] ?? ''),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.edit, size: 16.r, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              data['displayName'] ?? 'User',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              data['email'] ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            SizedBox(height: 32.h),

            // Stats Cards
            Row(
              children: [
                Expanded(child: _buildStatCard(theme, 'Orders', controller.totalOrders.value.toString(), Icons.shopping_bag_outlined)),
                SizedBox(width: 16.w),
                Expanded(child: _buildStatCard(theme, 'Points', '124', Icons.stars_outlined)),
              ],
            ),
            SizedBox(height: 32.h),

            // Menu Options
            _buildMenuTile(
              theme,
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              onTap: () => _showEditProfileDialog(context, data['displayName'] ?? ''),
            ),
            _buildMenuTile(
              theme,
              icon: Icons.history,
              title: 'My Orders',
              onTap: () => homeController.onBottomNavChanged(3),
            ),
            _buildMenuTile(
              theme,
              icon: Icons.favorite_border,
              title: 'Favorites',
              onTap: () => homeController.onBottomNavChanged(1),
            ),
            _buildMenuTile(
              theme,
              icon: Icons.location_on_outlined,
              title: 'Delivery Addresses',
              onTap: () => Get.toNamed('/addresses'),
            ),
            _buildMenuTile(
              theme,
              icon: Icons.payment,
              title: 'Payment Methods',
              onTap: () {},
            ),
            _buildMenuTile(
              theme,
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => Get.to(() => const SettingsPage()),
            ),
            SizedBox(height: 32.h),
            
            _buildMenuTile(
              theme,
              icon: Icons.logout,
              title: 'Log Out',
              onTap: () => _showLogoutDialog(context),
              titleColor: theme.colorScheme.error,
              iconColor: theme.colorScheme.error,
            ),
          ],
        ),
      );
    });
  }

  void _showEditProfileDialog(BuildContext context, String currentName) {
    final nameController = TextEditingController(text: currentName);
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Get.back();
                controller.updateProfile(displayName: nameController.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24.r),
          SizedBox(height: 8.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: titleColor ?? theme.colorScheme.onSurface,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/delivery/delivery_controller.dart';
import 'package:tasty_go/presentation/navigation/app_routes.dart';
import 'package:tasty_go/presentation/controllers/theme_controller.dart';

class DeliveryLayout extends GetView<DeliveryController> {
  final Widget child;
  final String title;

  const DeliveryLayout({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(title),
              automaticallyImplyLeading: true,
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
            ),
      drawer: isDesktop ? null : Builder(builder: (context) => _buildSidebar(context)),
      body: Row(
        children: [
          if (isDesktop) Builder(builder: (context) => _buildSidebar(context)),
          Expanded(
            child: Container(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 260,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSidebarHeader(theme),
            const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  route: Routes.deliveryHome,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.delivery_dining_outlined,
                  activeIcon: Icons.delivery_dining,
                  label: 'My Deliveries',
                  route: Routes.deliveryActive,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  label: 'History',
                  route: Routes.deliveryHistory,
                ),
                const Divider(height: 32),
                _buildNavItem(
                  context: context,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  route: Routes.deliveryProfile,
                ),
              ],
            ),
          ),
          _buildThemeToggle(theme),
          _buildLogoutButton(theme),
          const SizedBox(height: 20),
        ],
      ),
    ),
    );
  }

  Widget _buildSidebarHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.restaurant,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'TastyGo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Partner',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
  }) {
    return Obx(() {
      final isActive = controller.currentRoute.value == route;
      final theme = Get.theme;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () {
            print('🔵 [DELIVERY_NAV] Tapped: $route');
            
            // Close drawer if open (for mobile)
            final scaffold = Scaffold.maybeOf(context);
            if (scaffold != null && scaffold.isDrawerOpen) {
              Navigator.pop(context);
            }
            
            if (controller.currentRoute.value != route) {
              print('🔵 [DELIVERY_NAV] Navigating to: $route');
              controller.currentRoute.value = route;
              Get.toNamed(route);
            } else {
              print('🔵 [DELIVERY_NAV] Already on: $route');
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildThemeToggle(ThemeData theme) {
    final themeController = Get.find<ThemeController>();
    return Obx(() => ListTile(
      leading: Icon(
        themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Colors.grey,
      ),
      title: const Text('Dark Mode', style: TextStyle(color: Colors.grey, fontSize: 14)),
      trailing: Switch(
        value: themeController.isDarkMode,
        onChanged: (val) => themeController.switchTheme(),
      ),
    ));
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => _showLogoutDialog(theme),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: theme.colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

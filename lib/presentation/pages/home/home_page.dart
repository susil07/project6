import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/home/home_controller.dart';
import 'package:tasty_go/presentation/pages/home/widgets/home_widgets.dart';
import 'package:tasty_go/presentation/pages/auth/auth_controller.dart';
import 'package:tasty_go/presentation/widgets/cart_icon_badge.dart';
import 'package:tasty_go/presentation/controllers/theme_controller.dart';
import 'package:tasty_go/presentation/pages/favorites/favorites_page.dart';
import 'package:tasty_go/presentation/pages/favorites/favorites_controller.dart';
import 'package:tasty_go/presentation/pages/profile/user_profile_page.dart';
import 'package:tasty_go/presentation/pages/profile/user_profile_controller.dart';
import 'package:tasty_go/presentation/pages/orders/orders_page.dart';
import 'package:tasty_go/presentation/pages/orders/orders_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1200;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: isDesktop ? null : const _MobileDrawer(),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop) const _Sidebar(),
            Expanded(child: _MainContent()),
          ],
        ),
      ),
      bottomNavigationBar: isDesktop ? null : const _BottomNav(),
      floatingActionButton: Obx(() => controller.allFoodItems.isEmpty && !controller.isLoading.value
          ? FloatingActionButton.extended(
              onPressed: controller.isSeeding.value ? null : controller.seedSampleData,
              icon: controller.isSeeding.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add),
              label: Text(controller.isSeeding.value ? 'Adding...' : 'Add Sample Data'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            )
          : const SizedBox.shrink()),
    );
  }
}

// Sidebar for desktop
class _Sidebar extends GetView<HomeController> {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 260,
      color: theme.colorScheme.surfaceContainer,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.restaurant, color: theme.colorScheme.primary, size: 40),
          const SizedBox(height: 40),
          Obx(() => _SideItem(Icons.home, 'Home', controller.selectedBottomIndex.value == 0, onTap: () => controller.onBottomNavChanged(0))),
          Obx(() => _SideItem(Icons.favorite, 'Favorites', controller.selectedBottomIndex.value == 1, onTap: () => controller.onBottomNavChanged(1))),
          Obx(() => _SideItem(Icons.person, 'Profile', controller.selectedBottomIndex.value == 2, onTap: () => controller.onBottomNavChanged(2))),
          Obx(() => _SideItem(Icons.history, 'History', controller.selectedBottomIndex.value == 3, onTap: () => controller.onBottomNavChanged(3))),
          const Spacer(),
          _buildThemeToggle(context),
          _SideItem(
            Icons.logout,
            'Logout',
            false,
            onTap: () => _showLogoutDialog(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(() => ListTile(
      leading: Icon(
        themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Colors.grey,
      ),
      title: const Text('Dark Mode', style: TextStyle(color: Colors.grey)),
      trailing: Switch(
        value: themeController.isDarkMode,
        onChanged: (val) => themeController.switchTheme(),
      ),
    ));
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
              Get.find<AuthController>().logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _SideItem(this.icon, this.label, this.active, {this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: active ? theme.colorScheme.primary : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          color: active ? theme.colorScheme.primary : Colors.grey,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

// Main Content
class _MainContent extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    // Ensure controllers are initialized when their respective pages are accessed
    // This is a common pattern with GetX for lazy loading controllers
    Get.lazyPut(() => FavoritesController());
    Get.lazyPut(() => UserProfileController());
    Get.lazyPut(() => OrdersController());

    return Obx(() => IndexedStack(
          index: controller.selectedBottomIndex.value,
          children: [
            _buildHomeContent(context),
            const FavoritesPage(),
            const UserProfilePage(),
            const OrdersPage(),
          ],
        ));
  }

  Widget _buildHomeContent(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: width < 600 ? 20 : 48,
            vertical: 32,
          ),
          sliver: SliverToBoxAdapter(child: _Header()),
        ),
        SliverToBoxAdapter(child: _CategoryBar()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
          sliver: _ProductGrid(),
        ),
      ],
    );
  }
}

// Header
class _Header extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: theme.colorScheme.onSurface),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const CartIconBadge(),
            ],
          ),
        const SizedBox(height: 24),
        Text(
          'Delicious\nfood for you',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: isMobile ? double.infinity : 420,
          child: const SearchField(),
        ),
      ],
    );
  }
}

// Category Bar
class _CategoryBar extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 32),
        itemBuilder: (context, index) {
          final cat = controller.categories[index];
          return Obx(() => CategoryChip(
                label: cat,
                isSelected: controller.selectedCategory.value == cat,
                onTap: () => controller.onCategoryChanged(cat),
              ));
        },
      ),
    );
  }
}

// Product Grid - Responsive Magic
class _ProductGrid extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredItems;
      final width = MediaQuery.of(context).size.width;

      if (items.isEmpty && !controller.isLoading.value) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found for "${controller.searchQuery.value}"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => controller.onSearchChanged(''),
                  child: const Text('Clear Search'),
                ),
              ],
            ),
          ),
        );
      }
      
      return SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: width < 600
              ? 220
              : width < 900
                  ? 260
                  : 320,
          mainAxisSpacing: 40,
          crossAxisSpacing: 32,
          childAspectRatio: 0.78,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ProductCard(item: items[index]),
          childCount: items.length,
        ),
      );
    });
  }
}

// Bottom Navigation
class _BottomNav extends GetView<HomeController> {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() => BottomNavigationBar(
          backgroundColor: theme.colorScheme.surface,
          currentIndex: controller.selectedBottomIndex.value,
          onTap: controller.onBottomNavChanged,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          ],
        ));
  }
}

class _MobileDrawer extends GetView<HomeController> {
  const _MobileDrawer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, color: Colors.white, size: 48.sp),
                  SizedBox(height: 8.h),
                  Text(
                    'TastyGo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              controller.onBottomNavChanged(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
              controller.onBottomNavChanged(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              controller.onBottomNavChanged(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.pop(context);
              controller.onBottomNavChanged(3);
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
          SizedBox(height: 16.h),
        ],
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
              Get.find<AuthController>().logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

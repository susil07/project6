import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/admin/layout/admin_layout.dart';
import 'package:tasty_go/presentation/pages/admin/home/admin_home_controller.dart';

class AdminHomePage extends GetView<AdminHomeController> {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AdminLayout(
      title: 'Dashboard',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Overview',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 24.h),
            
            // Stats Cards
            Obx(() => Wrap(
              spacing: 16.w,
              runSpacing: 16.h,
              children: [
                _buildStatCard(
                  theme,
                  title: 'Total Users',
                  value: controller.totalUsers.value.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  theme,
                  title: 'Pending Approvals',
                  value: controller.pendingUsers.value.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  theme,
                  title: 'Active Orders',
                  value: controller.activeOrders.value.toString(),
                  icon: Icons.shopping_cart,
                  color: Colors.green,
                ),
                _buildStatCard(
                  theme,
                  title: 'Total Orders',
                  value: controller.totalOrders.value.toString(),
                  icon: Icons.history,
                  color: Colors.indigo,
                ),
                _buildStatCard(
                  theme,
                  title: 'Total Food Items',
                  value: controller.totalFoodItems.value.toString(),
                  icon: Icons.restaurant_menu,
                  color: Colors.purple,
                ),
              ],
            )),
            
            SizedBox(height: 32.h),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            
            Wrap(
              spacing: 16.w,
              runSpacing: 16.h,
              children: [
                _buildActionButton(
                  theme,
                  label: 'Manage Users',
                  icon: Icons.people,
                  onTap: () => Get.toNamed('/admin/users'),
                ),
                _buildActionButton(
                  theme,
                  label: 'Manage Food',
                  icon: Icons.restaurant_menu,
                  onTap: () => Get.toNamed('/admin/food'),
                ),
                _buildActionButton(
                  theme,
                  label: 'View Orders',
                  icon: Icons.receipt_long,
                  onTap: () => Get.toNamed('/admin/orders'),
                ),
                _buildActionButton(
                  theme,
                  label: 'Setup Restaurant',
                  icon: Icons.store,
                  onTap: () => controller.seedRestaurantData(),
                ),
              ],
            ),
            
            SizedBox(height: 32.h),
            
            // Recent Activity
            Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            
            Obx(() {
              if (controller.recentOrders.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(32.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                  ),
                  child: const Center(child: Text('No recent orders')),
                );
              }
              
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.recentOrders.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final order = controller.recentOrders[index];
                    return ListTile(
                      title: Text('Order #${order['id'].toString().substring(0, 8).toUpperCase()}'),
                      subtitle: Text(order['deliveryAddress']?.toString().split(',').first ?? 'User'),
                      trailing: _buildSmallStatusChip(theme, order['status'] ?? 'pending'),
                      onTap: () => Get.toNamed('/admin/orders'),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatusChip(ThemeData theme, String status) {
    Color color = Colors.grey;
    switch (status) {
      case 'pending': color = Colors.orange; break;
      case 'confirmed': color = Colors.blue; break;
      case 'preparing': color = Colors.purple; break;
      case 'out_for_delivery': color = Colors.indigo; break;
      case 'delivered': color = Colors.green; break;
      case 'cancelled': color = Colors.red; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 240.w,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    ThemeData theme, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 180.w,
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

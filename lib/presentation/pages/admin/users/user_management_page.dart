import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/admin/layout/admin_layout.dart';
import 'package:tasty_go/presentation/pages/admin/users/user_management_controller.dart';
import 'package:tasty_go/data/models/user_model.dart';

class UserManagementPage extends GetView<UserManagementController> {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1200;
    
    return AdminLayout(
      title: 'Manage Users',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'User Management',
                    style: TextStyle(
                      fontSize: (width < 600 ? 20 : 28).sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            
            // Filter Chips
            Obx(() => Wrap(
              spacing: 12.w,
              children: [
                _buildFilterChip(theme, 'All Users', 'all'),
                _buildFilterChip(theme, 'Pending', 'pending'),
                _buildFilterChip(theme, 'Approved', 'approved'),
                _buildFilterChip(theme, 'Blocked', 'blocked'),
              ],
            )),
            
            SizedBox(height: 24.h),
            
            // Users List
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredUsers.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.h),
                    child: Text(
                      'No users found',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                );
              }
              
              return isDesktop 
                  ? _buildDataTable(theme)
                  : _buildUserCards(theme);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, String value) {
    final isSelected = controller.selectedFilter.value == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.setFilter(value),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildDataTable(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
        ),
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          theme.colorScheme.primary.withValues(alpha: 0.05),
        ),
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: controller.filteredUsers.map((user) {
          return DataRow(
            cells: [
              DataCell(Text(user.displayName)),
              DataCell(Text(user.email)),
              DataCell(_buildRoleBadge(theme, user.role)),
              DataCell(_buildStatusBadge(theme, user.status)),
              DataCell(_buildActions(theme, user)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserCards(ThemeData theme) {
    return Column(
      children: controller.filteredUsers.map((user) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      user.displayName.isNotEmpty ? user.displayName[0] : 'U',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _buildRoleBadge(theme, user.role),
                  SizedBox(width: 8.w),
                  _buildStatusBadge(theme, user.status),
                ],
              ),
              SizedBox(height: 12.h),
              _buildActions(theme, user),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoleBadge(ThemeData theme, String role) {
    Color color;
    String label;
    
    switch (role) {
      case 'admin':
        color = Colors.purple;
        label = 'Admin';
        break;
      case 'delivery_partner':
        color = Colors.blue;
        label = 'Delivery';
        break;
      default:
        color = Colors.green;
        label = 'User';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, String status) {
    Color color;
    
    switch (status) {
      case 'approved':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'blocked':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions(ThemeData theme, UserModel user) {
    // Don't show actions for admins
    if (user.isAdmin) {
      return const SizedBox.shrink();
    }
    
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        if (user.isPending) ...[
          _buildActionButton(
            label: 'Approve',
            icon: Icons.check,
            color: Colors.green,
            onTap: () => controller.approveUser(user.uid),
          ),
          _buildActionButton(
            label: 'Reject',
            icon: Icons.close,
            color: Colors.red,
            onTap: () => _showRejectDialog(user.uid),
          ),
        ],
        if (user.isApproved)
          _buildActionButton(
            label: 'Block',
            icon: Icons.block,
            color: Colors.red,
            onTap: () => _showBlockDialog(user.uid),
          ),
        if (user.isBlocked)
          _buildActionButton(
            label: 'Unblock',
            icon: Icons.check_circle,
            color: Colors.green,
            onTap: () => controller.unblockUser(user.uid),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(String userId) {
    final reasonController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Reject User'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
            hintText: 'Enter reason for rejection',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.rejectUser(userId, reasonController.text);
              Get.back();
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(String userId) {
    final reasonController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Block User'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
            hintText: 'Enter reason for blocking',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.blockUser(userId, reasonController.text);
              Get.back();
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}

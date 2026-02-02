import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/admin/layout/admin_layout.dart';
import 'package:tasty_go/presentation/pages/admin/orders/admin_orders_controller.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:intl/intl.dart';

class AdminOrdersPage extends GetView<AdminOrdersController> {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1200;

    return AdminLayout(
      title: 'Manage Orders',
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Orders Management',
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
            
            // Status Tabs
            Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'placed', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled']
                    .map((status) => Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: ChoiceChip(
                            label: Text(status.toUpperCase()),
                            selected: controller.selectedStatus.value == status,
                            onSelected: (selected) => controller.selectedStatus.value = status,
                          ),
                        ))
                    .toList(),
              ),
            )),
            SizedBox(height: 24.h),
            
            // Orders List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredOrders.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return isDesktop ? _buildDataTable(theme) : _buildMobileList(theme);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.1)),
        ),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Order ID')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Address')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: controller.filteredOrders.map((order) {
            return DataRow(cells: [
              DataCell(Text('#${order.id.substring(0, 8).toUpperCase()}')),
              DataCell(Text(order.userName)),
              DataCell(Text(order.address, overflow: TextOverflow.ellipsis)),
              DataCell(Text('₹${order.totalPrice.toStringAsFixed(2)}')),
              DataCell(_buildStatusBadge(theme, order.status)),
              DataCell(_buildActionMenu(theme, order)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(ThemeData theme) {
    return ListView.builder(
      itemCount: controller.filteredOrders.length,
      itemBuilder: (context, index) {
        final order = controller.filteredOrders[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: ExpansionTile(
            title: Text('#${order.id.substring(0, 8).toUpperCase()} - ${order.userName}'),
            subtitle: Text('₹${order.totalPrice.toStringAsFixed(2)} • ${order.status}'),
            trailing: _buildStatusBadge(theme, order.status),
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Address: ${order.address}'),
                    SizedBox(height: 8.h),
                    Text('Date: ${DateFormat('MMM dd, hh:mm a').format(order.createdAt)}'),
                    SizedBox(height: 16.h),
                    const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...order.items.map((item) => Text('${item.quantity}x ${item.name}')),
                    SizedBox(height: 16.h),
                    _buildActionButtons(theme, order),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(ThemeData theme, String status) {
    Color color;
    switch (status) {
      case 'delivered': color = Colors.green; break;
      case 'cancelled': color = Colors.red; break;
      case 'out_for_delivery': color = Colors.blue; break;
      case 'preparing': color = Colors.orange; break;
      case 'confirmed': color = Colors.teal; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10.sp, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionMenu(ThemeData theme, FoodOrder order) {
    return PopupMenuButton<String>(
      onSelected: (status) => controller.updateStatus(order.id, status),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'confirmed', child: Text('Confirm')),
        const PopupMenuItem(value: 'preparing', child: Text('Preparing')),
        const PopupMenuItem(value: 'out_for_delivery', child: Text('Out for Delivery')),
        const PopupMenuItem(value: 'delivered', child: Text('Delivered')),
        const PopupMenuItem(value: 'cancelled', child: Text('Cancel')),
      ],
      child: const Icon(Icons.more_vert),
    );
  }

  Widget _buildActionButtons(ThemeData theme, FoodOrder order) {
    return Wrap(
      spacing: 8.w,
      children: [
        if (order.status == 'placed')
          ElevatedButton(onPressed: () => controller.updateStatus(order.id, 'confirmed'), child: const Text('Confirm')),
        if (order.status == 'confirmed')
          ElevatedButton(onPressed: () => controller.updateStatus(order.id, 'preparing'), child: const Text('Start Preparing')),
        if (order.status == 'preparing')
          ElevatedButton(onPressed: () => controller.updateStatus(order.id, 'out_for_delivery'), child: const Text('Out for Delivery')),
      ],
    );
  }
}

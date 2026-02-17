import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/delivery/layout/delivery_layout.dart';
import 'package:tasty_go/presentation/pages/delivery/active/delivery_active_orders_controller.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:intl/intl.dart';

class DeliveryActiveOrdersPage extends GetView<DeliveryActiveOrdersController> {
  const DeliveryActiveOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DeliveryLayout(
      title: 'Active Deliveries',
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.activeOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delivery_dining, size: 64.sp, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                SizedBox(height: 16.h),
                Text(
                  'No active deliveries',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.activeOrders.length,
          itemBuilder: (context, index) {
            final order = controller.activeOrders[index];
            return _buildOrderCard(theme, order);
          },
        );
      }),
    );
  }

  Widget _buildOrderCard(ThemeData theme, FoodOrder order) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id.substring(0, 8).toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(theme, order.status),
              ],
            ),
            SizedBox(height: 12.h),
            const Divider(),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.location_on, size: 16.sp, color: theme.colorScheme.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    order.address,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 16.sp, color: theme.colorScheme.onSurfaceVariant),
                SizedBox(width: 8.w),
                Text(
                  DateFormat('MMM dd, hh:mm a').format(order.createdAt),
                  style: TextStyle(fontSize: 12.sp, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Items:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            ...order.items.map((item) => Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Row(
                children: [
                  Text('${item.quantity}x', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                  SizedBox(width: 8.w),
                  Text(item.name, style: TextStyle(fontSize: 12.sp)),
                ],
              ),
            )),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.status == 'confirmed' || order.status == 'preparing')
                  ElevatedButton(
                    onPressed: () => controller.updateStatus(order.id, 'out_for_delivery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: const Text('Start Delivery'),
                  ),
                if (order.status == 'out_for_delivery')
                  ElevatedButton(
                    onPressed: () => controller.updateStatus(order.id, 'delivered'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Mark as Delivered'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'out_for_delivery':
        color = Colors.blue;
        label = 'Out for Delivery';
        break;
      case 'preparing':
        color = Colors.orange;
        label = 'Preparing';
        break;
      case 'confirmed':
        color = Colors.green;
        label = 'Confirmed';
        break;
      case 'delivered':
        color = Colors.green;
        label = 'Delivered';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status.replaceAll('_', ' ').capitalizeFirst ?? status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

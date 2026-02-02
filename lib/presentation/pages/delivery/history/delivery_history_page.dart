import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/delivery/layout/delivery_layout.dart';
import 'package:tasty_go/presentation/pages/delivery/history/delivery_history_controller.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:intl/intl.dart';

class DeliveryHistoryPage extends GetView<DeliveryHistoryController> {
  const DeliveryHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DeliveryLayout(
      title: 'Delivery History',
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.historyOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64.sp, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                SizedBox(height: 16.h),
                Text(
                  'No delivery history',
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
          itemCount: controller.historyOrders.length,
          itemBuilder: (context, index) {
            final order = controller.historyOrders[index];
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
                Icon(Icons.calendar_today, size: 16.sp, color: theme.colorScheme.onSurfaceVariant),
                SizedBox(width: 8.w),
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt),
                  style: TextStyle(fontSize: 12.sp, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurfaceVariant),
                ),
                Text(
                  '₹${order.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
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
    switch (status) {
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
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
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

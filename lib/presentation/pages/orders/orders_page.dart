import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:tasty_go/presentation/pages/orders/orders_controller.dart';

class OrdersPage extends GetView<OrdersController> {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Text(
            'My Orders',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(theme, 'All', 'all'),
                _buildFilterChip(theme, 'Active', 'active'),
                _buildFilterChip(theme, 'Completed', 'completed'),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64.sp, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text(
                        'No orders found',
                        style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: controller.filteredOrders.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final order = controller.filteredOrders[index];
                  return _buildOrderCard(context, order);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, String value) {
    return Obx(() {
      final isSelected = controller.currentFilter.value == value;
      return Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (bool selected) {
            if (selected) controller.setFilter(value);
          },
          backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: BorderSide(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            ),
          ),
          showCheckmark: false,
        ),
      );
    });
  }

  Widget _buildOrderCard(BuildContext context, FoodOrder order) {
    final theme = Theme.of(context);
    
    return Container(
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
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      DateFormat('MMM d, y • h:mm a').format(order.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(theme, order.status),
              ],
            ),
          ),
          
          Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1)),
          
          // Items Preview
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: order.items.take(2).map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}x',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(fontSize: 14.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1)),

          // Footer
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '₹${order.total.toInt()}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8.w,
                  children: [
                    if (order.isDelivered || order.isCancelled)
                      OutlinedButton.icon(
                        onPressed: () => controller.reorder(order),
                        icon: Icon(Icons.refresh, size: 16.sp),
                        label: const Text('Reorder'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.colorScheme.primary),
                          foregroundColor: theme.colorScheme.primary,
                        ),
                      ),
                    if (!order.isDelivered && !order.isCancelled)
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.toNamed('/order-tracking/${order.id}');
                        },
                        icon: Icon(Icons.map, size: 18.sp),
                        label: const Text('Track'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => _showOrderDetails(context, order),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, FoodOrder order) {
    final theme = Theme.of(context);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              SizedBox(height: 16.h),
              _buildSimpleDetailRow('Status', order.status.replaceAll('_', ' ').capitalizeFirst ?? order.status),
              _buildSimpleDetailRow('Order ID', '#${order.id.toUpperCase()}'),
              _buildSimpleDetailRow('Date', DateFormat('MMM d, y, h:mm a').format(order.createdAt)),
              _buildSimpleDetailRow('Payment', order.paymentMethod.toUpperCase()),
              SizedBox(height: 16.h),
              const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              ...order.items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.quantity}x ${item.name}'),
                    Text('₹${item.totalPrice.toInt()}'),
                  ],
                ),
              )),
              const Divider(),
              _buildSimpleDetailRow('Subtotal', '₹${order.subtotal.toInt()}'),
              _buildSimpleDetailRow('Delivery Fee', '₹${order.deliveryFee.toInt()}'),
              _buildSimpleDetailRow('Tax', '₹${order.tax.toInt()}'),
              const Divider(),
              _buildSimpleDetailRow('Total', '₹${order.total.toInt()}', isBold: true),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16.sp : 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, String status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.access_time;
        label = 'Pending';
        break;
      case 'confirmed':
        color = Colors.blue;
        icon = Icons.thumb_up;
        label = 'Confirmed';
        break;
      case 'preparing':
        color = Colors.purple;
        icon = Icons.restaurant;
        label = 'Preparing';
        break;
      case 'out_for_delivery':
        color = Colors.teal;
        icon = Icons.delivery_dining;
        label = 'Out for Delivery';
        break;
      case 'delivered':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Delivered';
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
        label = status.replaceAll('_', ' ').capitalizeFirst ?? status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

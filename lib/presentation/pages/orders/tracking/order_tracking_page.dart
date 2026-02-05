import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tasty_go/presentation/pages/orders/tracking/order_tracking_controller.dart';
import 'package:intl/intl.dart';

class OrderTrackingPage extends GetView<OrderTrackingController> {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Google Map
          SizedBox.expand(
            child: Obx(() => GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(12.9716, 77.5946), // Default to Bangalore
                zoom: 13,
              ),
              onMapCreated: (mapController) {
                print('DEBUG: onMapCreated CALLBACK TRIGGERED');
                controller.onMapCreated(mapController);
              },
              markers: controller.markers.toSet(),
              polylines: controller.polylines.toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
            )),
          ),

          // Loading Overlay
          Obx(() {
            if (!controller.isMapLoading.value) return const SizedBox.shrink();
            
            return Container(
              color: theme.colorScheme.surface,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Initializing Map...'),
                  ],
                ),
              ),
            );
          }),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16.w,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ),
          ),

          // Order Status Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildOrderInfoSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoSheet(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          Obx(() {
            final order = controller.currentOrder.value;
            if (order == null) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusTitle(order.status),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        if (order.estimatedDeliveryMinutes != null && !order.isDelivered)
                          Text(
                            'Arriving in ${order.estimatedDeliveryMinutes!.toStringAsFixed(0)} mins',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else if (order.isDelivered)
                          Text(
                            'Delivered at ${DateFormat('h:mm a').format(order.deliveredAt ?? DateTime.now())}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(order.status),
                        color: theme.colorScheme.primary,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Progress Bar
                _buildProgressBar(theme, order.status),
                SizedBox(height: 24.h),

                // Restaurant Address
                if (order.restaurantName != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.store, color: theme.colorScheme.primary, size: 20.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Picking up from',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                order.restaurantName!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              if (order.restaurantAddress != null)
                                Text(
                                  order.restaurantAddress!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Delivery Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Location',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            order.deliveryAddress,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Delivery Partner Info (Placeholder)
                if (order.status == 'out_for_delivery')
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person, color: Colors.grey[600]),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery Partner',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Ramesh Kumar',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.phone),
                          color: theme.colorScheme.primary,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme, String status) {
    int currentStep = 0;
    switch (status) {
      case 'confirmed': currentStep = 1; break;
      case 'preparing': currentStep = 2; break;
      case 'out_for_delivery': currentStep = 3; break;
      case 'delivered': currentStep = 4; break;
    }

    return Row(
      children: List.generate(4, (index) {
        final isActive = index < currentStep;
        return Expanded(
          child: Container(
            height: 4.h,
            margin: EdgeInsets.only(right: index < 3 ? 4.w : 0),
            decoration: BoxDecoration(
              color: isActive ? theme.colorScheme.primary : Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );
      }),
    );
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'pending': return 'Order Placed';
      case 'confirmed': return 'Order Confirmed';
      case 'preparing': return 'Food is Preparing';
      case 'out_for_delivery': return 'Out for Delivery';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Order Cancelled';
      default: return 'Processing';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.receipt_long;
      case 'confirmed': return Icons.thumb_up;
      case 'preparing': return Icons.restaurant;
      case 'out_for_delivery': return Icons.delivery_dining;
      case 'delivered': return Icons.check_circle;
      case 'cancelled': return Icons.cancel;
      default: return Icons.info;
    }
  }
}

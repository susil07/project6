import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/delivery/layout/delivery_layout.dart';
import 'package:tasty_go/presentation/pages/delivery/home/delivery_home_controller.dart';
import 'package:tasty_go/data/models/order_model.dart';
import 'package:intl/intl.dart';

class DeliveryHomePage extends GetView<DeliveryHomeController> {
  const DeliveryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DeliveryLayout(
      title: 'Dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(theme),
            const SizedBox(height: 32),
            _buildTrackingStatus(theme),
            const SizedBox(height: 32),
            _buildSectionTitle(theme, 'My Active Orders'),
            const SizedBox(height: 16),
            _buildAssignedOrders(theme),
            const SizedBox(height: 32),
            _buildSectionTitle(theme, 'Available Orders Near You'),
            const SizedBox(height: 16),
            _buildAvailableOrders(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello Delivery Partner!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your deliveries and track your earnings.',
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingStatus(ThemeData theme) {
    return Obx(() {
      final isStreaming = controller.isLocationStreaming.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isStreaming 
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isStreaming ? Colors.green : Colors.orange,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isStreaming ? Icons.location_on : Icons.location_off,
              color: isStreaming ? Colors.green : Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isStreaming ? 'Location Tracking Active' : 'Tracking Inactive',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isStreaming ? Colors.green : Colors.orange,
                    ),
                  ),
                  Text(
                    isStreaming 
                        ? 'Sharing your real-time location with customers.'
                        : 'Tracking starts automatically when you pick up an order.',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildAssignedOrders(ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.assignedOrders.isEmpty) {
        return _buildEmptyState(
          theme,
          Icons.delivery_dining,
          'No active orders',
          'Accept available orders below to start delivering.',
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.assignedOrders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final order = controller.assignedOrders[index];
          return _buildOrderCard(theme, order, isAssigned: true);
        },
      );
    });
  }

  Widget _buildAvailableOrders(ThemeData theme) {
    return Obx(() {
      if (controller.availableOrders.isEmpty) {
        return _buildEmptyState(
          theme,
          Icons.search,
          'Searching for orders...',
          'No new orders available currently.',
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.availableOrders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final order = controller.availableOrders[index];
          return _buildOrderCard(theme, order, isAssigned: false);
        },
      );
    });
  }

  Widget _buildOrderCard(ThemeData theme, FoodOrder order, {required bool isAssigned}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildStatusChip(theme, order.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM d, h:mm a').format(order.createdAt),
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              const Spacer(),
              Text(
                'Total: ₹${order.total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: isAssigned
                    ? _buildStatusButtons(theme, order)
                    : ElevatedButton(
                        onPressed: () => controller.acceptOrder(order.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Accept Order'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButtons(ThemeData theme, FoodOrder order) {
    if (order.status == 'confirmed' || order.status == 'preparing') {
      return ElevatedButton.icon(
        onPressed: () => controller.updateStatus(order.id, 'out_for_delivery'),
        icon: const Icon(Icons.shopping_bag_outlined),
        label: const Text('Picked Up'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (order.status == 'out_for_delivery') {
      return ElevatedButton.icon(
        onPressed: () => controller.updateStatus(order.id, 'delivered'),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Mark as Delivered'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatusChip(ThemeData theme, String status) {
    Color color = Colors.grey;
    String label = status.replaceAll('_', ' ').capitalizeFirst ?? status;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'confirmed':
        color = Colors.blue;
        label = 'Confirmed';
        break;
      case 'preparing':
        color = Colors.purple;
        label = 'Preparing';
        break;
      case 'out_for_delivery':
        color = Colors.indigo;
        label = 'Out for Delivery';
        break;
      case 'delivered':
        color = Colors.green;
        label = 'Delivered';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, IconData icon, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

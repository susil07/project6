import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/controllers/cart_controller.dart';

class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Shopping Cart',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.cartItems.isNotEmpty) {
              return TextButton.icon(
                onPressed: () => _showClearCartDialog(context),
                icon: Icon(Icons.delete_outline, color: Colors.red),
                label: Text(
                  'Clear',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          SizedBox(width: 16.w),
        ],
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return _buildEmptyCart(theme);
        }
        
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return _buildCartItemCard(theme, item);
                },
              ),
            ),
            _buildPriceSummary(theme),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          SizedBox(height: 24.h),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add some delicious food to get started!',
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Browse Menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(ThemeData theme, item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              item.imageUrl,
              width: 80.w,
              height: 80.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80.w,
                  height: 80.h,
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  child: Icon(Icons.fastfood, size: 40.sp),
                );
              },
            ),
          ),
          SizedBox(width: 12.w),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '₹${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.specialInstructions != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Note: ${item.specialInstructions}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 12.w),
          
          // Quantity controls
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => controller.decrementQuantity(item),
                    icon: Icon(
                      item.quantity == 1 ? Icons.delete_outline : Icons.remove,
                      size: 20.sp,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      padding: EdgeInsets.all(8.w),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      item.quantity.toString(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.incrementQuantity(item),
                    icon: Icon(Icons.add, size: 20.sp),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      foregroundColor: theme.colorScheme.primary,
                      padding: EdgeInsets.all(8.w),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '₹${item.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriceRow(theme, 'Subtotal', controller.subtotal),
            SizedBox(height: 8.h),
            _buildPriceRow(theme, 'Tax (5%)', controller.tax),
            SizedBox(height: 8.h),
            _buildPriceRow(theme, 'Delivery Fee', controller.deliveryFee),
            Divider(height: 24.h),
            _buildPriceRow(
              theme,
              'Total',
              controller.total,
              isTotal: true,
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed('/checkout');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    ThemeData theme,
    String label,
    double amount, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: FontWeight.bold,
            color: isTotal ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.clearCart();
              Get.back();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

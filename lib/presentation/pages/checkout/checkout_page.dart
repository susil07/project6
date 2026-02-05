import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/checkout/checkout_controller.dart';
import 'package:tasty_go/presentation/pages/profile/address/address_management_page.dart';
import 'package:tasty_go/data/models/address_model.dart';

class CheckoutPage extends GetView<CheckoutController> {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Checkout',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.w : 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            _buildSectionTitle(theme, 'Order Summary'),
            SizedBox(height: 12.h),
            _buildOrderSummary(theme),
            SizedBox(height: 24.h),

            // Delivery Address Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle(theme, 'Delivery Address'),
                TextButton.icon(
                  onPressed: () => Get.to(() => const AddressManagementPage()),
                  icon: const Icon(Icons.add),
                  label: const Text('Manage'),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            _buildAddressSelector(theme),
            SizedBox(height: 24.h),

            // Payment Method
            _buildSectionTitle(theme, 'Payment Method'),
            SizedBox(height: 12.h),
            _buildPaymentMethods(theme),
            SizedBox(height: 24.h),

            // Price Summary
            _buildPriceSummary(theme),
            SizedBox(height: 24.h),

            // Place Order Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: controller.isPlacingOrder.value
                        ? null
                        : controller.placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: controller.isPlacingOrder.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'PLACE ORDER',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                )),
            SizedBox(height: 24.h + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildAddressSelector(ThemeData theme) {
    return Obx(() {
      if (controller.isLoadingAddresses.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.addresses.isEmpty) {
        return InkWell(
          onTap: () => Get.to(() => const AddressManagementPage()),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Icon(Icons.add_location_alt, size: 32.sp, color: theme.colorScheme.primary),
                SizedBox(height: 8.h),
                const Text('Add Delivery Address'),
              ],
            ),
          ),
        );
      }

      return Column(
        children: controller.addresses.map((address) {
          final isSelected = controller.selectedAddress.value?.id == address.id;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: InkWell(
              onTap: () => controller.selectedAddress.value = address,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                    : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? theme.colorScheme.primary : Colors.grey,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                address.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              if (address.isDefault) ...[
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text('Default', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(address.fullAddress),
                          Text('${address.city} - ${address.pincode}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildOrderSummary(ThemeData theme) {
    return Obx(() => Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              ...controller.cartController.cartItems.map((item) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            item.imageUrl,
                            width: 50.w,
                            height: 50.h,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50.w,
                              height: 50.h,
                              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                              child: Icon(Icons.fastfood, size: 24.sp),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Qty: ${item.quantity}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${item.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ));
  }

  Widget _buildPaymentMethods(ThemeData theme) {
    return Obx(() => Column(
          children: [
            _buildPaymentOption(
              theme,
              'Cash on Delivery',
              'cod',
              Icons.money,
            ),
            SizedBox(height: 12.h),
            _buildPaymentOption(
              theme,
              'Online Payment',
              'online',
              Icons.credit_card,
            ),
          ],
        ));
  }

  Widget _buildPaymentOption(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
  ) {
    final isSelected = controller.selectedPaymentMethod.value == value;

    return InkWell(
      onTap: () => controller.selectedPaymentMethod.value = value,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(ThemeData theme) {
    return Obx(() => Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildPriceRow(
                theme,
                'Subtotal',
                controller.cartController.subtotal,
              ),
              SizedBox(height: 8.h),
              _buildPriceRow(
                theme,
                'Tax (5%)',
                controller.cartController.tax,
              ),
              SizedBox(height: 8.h),
              _buildPriceRow(
                theme,
                'Delivery Fee',
                controller.cartController.deliveryFee,
              ),
              Divider(height: 24.h),
              _buildPriceRow(
                theme,
                'Total',
                controller.cartController.total,
                isTotal: true,
              ),
            ],
          ),
        ));
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
            color:
                isTotal ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/checkout/checkout_controller.dart';

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

            // Delivery Address
            _buildSectionTitle(theme, 'Delivery Address'),
            SizedBox(height: 12.h),
            _buildAddressForm(theme),
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

  Widget _buildAddressForm(ThemeData theme) {
    return Column(
      children: [
        _buildTextField(
          controller: controller.fullNameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.person_outline,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: controller.phoneController,
          label: 'Phone Number',
          hint: 'Enter 10-digit phone number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: controller.addressLine1Controller,
          label: 'Address Line 1',
          hint: 'House/Flat No., Building Name',
          icon: Icons.home_outlined,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: controller.addressLine2Controller,
          label: 'Address Line 2 (Optional)',
          hint: 'Street, Area, Landmark',
          icon: Icons.location_on_outlined,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.cityController,
                label: 'City',
                hint: 'City',
                icon: Icons.location_city_outlined,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildTextField(
                controller: controller.pincodeController,
                label: 'Pincode',
                hint: '6-digit pincode',
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Get.theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Get.theme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
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

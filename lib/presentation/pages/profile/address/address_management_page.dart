import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/data/models/address_model.dart';
import 'package:tasty_go/presentation/pages/profile/address/address_management_controller.dart';
import 'package:tasty_go/presentation/pages/profile/address/add_address_page.dart';

class AddressManagementPage extends StatelessWidget {
  const AddressManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is loaded
    final controller = Get.put(AddressManagementController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                const Text('No saved addresses found. Add one now!'),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const AddAddressPage()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Address'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.addresses.length,
          itemBuilder: (context, index) {
            final address = controller.addresses[index];
            return _buildAddressCard(theme, address, controller);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddAddressPage()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAddressCard(ThemeData theme, AddressModel address, AddressManagementController controller) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: address.isDefault
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getIconForLabel(address.label),
                      color: theme.colorScheme.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
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
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      controller.deleteAddress(address.id);
                    } else if (value == 'default') {
                      controller.setDefault(address.id);
                    }
                  },
                  itemBuilder: (context) => [
                    if (!address.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Text('Set as Default'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(address.fullAddress),
            Text('${address.city} - ${address.pincode}'),
            SizedBox(height: 4.h),
            Text('Phone: ${address.phone}', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home': return Icons.home;
      case 'work': return Icons.work;
      default: return Icons.location_on;
    }
  }

}

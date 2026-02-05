import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tasty_go/presentation/pages/profile/address/address_management_controller.dart';

class AddAddressPage extends GetView<AddressManagementController> {
  const AddAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map (Top Half)
          Obx(() => controller.isMapLoading.value
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (mapController) {
                    controller.mapController = mapController;
                  },
                  initialCameraPosition: controller.initialCameraPosition,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false, // Custom button used
                  onCameraMove: controller.onCameraMove,
                  onCameraIdle: controller.onCameraIdle,
                  markers: {}, // No marker, use fixed center pin
                  zoomControlsEnabled: false,
                )),
          
          // 2. Fixed Center Pin
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35), // Adjust for pin bottom tip
              child: Icon(Icons.location_on, size: 45, color: Colors.red),
            ),
          ),

          // 3. Back Button
          Positioned(
            top: 40.h,
            left: 16.w,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          
          // 4. Locate Me Button (Above Sheet)
          Positioned(
            bottom: 470.h, // Positioned above the 450.h sheet
            right: 16.w,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              onPressed: controller.locateMe,
              icon: const Icon(Icons.my_location),
              label: const Text('Use Current Location'),
            ),
          ),

          // 5. Draggable/Fixed Bottom Sheet for Form
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 450.h, // Fixed height or could be DraggableScrollableSheet
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
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                   // Handle Bar
                   Container(
                     margin: EdgeInsets.only(top: 12.h),
                     width: 40.w,
                     height: 4.h,
                     decoration: BoxDecoration(
                       color: Colors.grey[300],
                       borderRadius: BorderRadius.circular(2.r),
                     ),
                   ),
                   Expanded(
                     child: SingleChildScrollView(
                       padding: EdgeInsets.fromLTRB(24.w, 24.w, 24.w, MediaQuery.of(context).padding.bottom + 24.h),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.stretch,
                         children: [
                           Text(
                             'Select Delivery Location',
                             style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                           ),
                           SizedBox(height: 16.h),
                           
                           // Location Details (Auto-filled)
                           Obx(() => Container(
                             padding: EdgeInsets.all(12.w),
                             decoration: BoxDecoration(
                               color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                               borderRadius: BorderRadius.circular(8.r),
                               border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                             ),
                             child: Row(
                               children: [
                                 Icon(Icons.location_on_outlined, color: theme.colorScheme.primary),
                                 SizedBox(width: 12.w),
                                 Expanded(
                                   child: controller.isGeocoding.value
                                     ? const Text('Fetching address...')
                                     : Text(
                                         controller.streetController.text.isNotEmpty 
                                            ? '${controller.streetController.text}, ${controller.cityController.text}'
                                            : 'Move map to select location',
                                         style: TextStyle(fontSize: 14.sp),
                                         maxLines: 2,
                                         overflow: TextOverflow.ellipsis,
                                       ),
                                 ),
                               ],
                             ),
                           )),
                           SizedBox(height: 16.h),
                           
                           // Manual Fields
                           Row(
                             children: [
                               Expanded(
                                 child: TextFormField(
                                   controller: controller.houseNoController,
                                   decoration: const InputDecoration(labelText: 'House No / Flat *'),
                                 ),
                               ),
                               SizedBox(width: 12.w),
                               Expanded(
                                 child: TextFormField(
                                   controller: controller.landmarkController,
                                   decoration: const InputDecoration(labelText: 'Landmark (Optional)'),
                                 ),
                               ),
                             ],
                           ),
                           SizedBox(height: 12.h),
                           
                           TextFormField(
                             controller: controller.phoneController,
                             decoration: const InputDecoration(labelText: 'Phone Number *'),
                             keyboardType: TextInputType.phone,
                           ),
                           SizedBox(height: 12.h),

                           Text('Save As', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                           SizedBox(height: 8.h),
                           
                           // Label Chips (Home/Work/Other)
                           Wrap(
                             spacing: 8.w,
                             children: [
                               _buildLabelChip(context, 'Home', Icons.home),
                               _buildLabelChip(context, 'Work', Icons.work),
                               _buildLabelChip(context, 'Other', Icons.location_on),
                             ],
                           ),
                           // Show text field if 'Other' is selected
                           Obx(() => controller.selectedLabel.value == 'Other' 
                             ? Padding(
                                 padding: EdgeInsets.only(top: 8.h),
                                 child: TextFormField(
                                   controller: controller.labelController,
                                   decoration: const InputDecoration(labelText: 'Custom Label (e.g. Partner\'s House)'),
                                 ),
                               )
                             : const SizedBox.shrink()
                           ),
                           SizedBox(height: 24.h),
                           
                           Obx(() => SizedBox(
                             width: double.infinity,
                             height: 50.h,
                             child: ElevatedButton(
                               onPressed: controller.isAddingAddress.value 
                                 ? null 
                                 : () => controller.saveAddress(),
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: theme.colorScheme.primary,
                                 foregroundColor: Colors.white,
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                               ),
                               child: controller.isAddingAddress.value 
                                   ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                                   : const Text('SAVE ADDRESS', style: TextStyle(fontWeight: FontWeight.bold)),
                             ),
                           )),
                         ],
                       ),
                     ),
                   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelChip(BuildContext context, String label, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedLabel.value == label;
      return FilterChip(
        label: Text(label),
        avatar: Icon(icon, size: 16.sp, color: isSelected ? Colors.white : Colors.grey),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) {
            controller.selectedLabel.value = label;
            if (label != 'Other') {
              controller.labelController.text = label;
            } else {
              controller.labelController.clear();
            }
          }
        },
        backgroundColor: Colors.transparent,
        checkmarkColor: Colors.white,
        selectedColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[300]!),
        ),
        showCheckmark: false,
      );
    });
  }
}

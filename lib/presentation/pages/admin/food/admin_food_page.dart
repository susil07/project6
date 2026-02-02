import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/admin/layout/admin_layout.dart';
import 'package:tasty_go/presentation/pages/admin/food/admin_food_controller.dart';
import 'package:tasty_go/data/models/food_item_model.dart';

class AdminFoodPage extends GetView<AdminFoodController> {
  const AdminFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1200;

    return AdminLayout(
      title: 'Food Items',
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Food Items Management',
                    style: TextStyle(
                      fontSize: (width < 600 ? 20 : 28).sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 16.w),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(context),
                  icon: const Icon(Icons.add),
                  label: Text(width < 600 ? 'Add' : 'Add Food Item'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            
            // Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => controller.searchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search food items...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                _buildCategoryDropdown(theme),
              ],
            ),
            SizedBox(height: 24.h),
            
            // List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredFoodItems.isEmpty) {
                  return const Center(child: Text('No food items found'));
                }

                return isDesktop ? _buildDataTable(theme) : _buildMobileList(theme);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButton<String>(
        value: controller.selectedCategory.value,
        underline: const SizedBox(),
        items: ['All', 'Burgers', 'Pizza', 'Drinks', 'Desserts', 'Snacks']
            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
            .toList(),
        onChanged: (val) => controller.selectedCategory.value = val!,
      ),
    ));
  }

  Widget _buildDataTable(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.1)),
        ),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Image')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Actions')),
          ],
          rows: controller.filteredFoodItems.map((item) {
            return DataRow(cells: [
              DataCell(
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(item.imageUrl, width: 40.w, height: 40.h, fit: BoxFit.cover, 
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.fastfood, size: 24.sp)),
                  ),
                ),
              ),
              DataCell(Text(item.name)),
              DataCell(Text(item.category)),
              DataCell(Text('₹${item.price}')),
              DataCell(Row(
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddEditDialog(Get.context!, item: item)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteConfirm(item.id)),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(ThemeData theme) {
    return ListView.builder(
      itemCount: controller.filteredFoodItems.length,
      itemBuilder: (context, index) {
        final item = controller.filteredFoodItems[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(item.imageUrl, width: 50.w, height: 50.h, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.fastfood, size: 32.sp)),
            ),
            title: Text(item.name),
            subtitle: Text('${item.category} • ₹${item.price}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showAddEditDialog(context, item: item);
                } else if (value == 'delete') {
                  _showDeleteConfirm(item.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddEditDialog(BuildContext context, {FoodItemModel? item}) {
    final nameController = TextEditingController(text: item?.name);
    final priceController = TextEditingController(text: item?.price);
    final imageController = TextEditingController(text: item?.imageUrl);
    final descController = TextEditingController(text: item?.description);
    String selectedCat = item?.category ?? 'Burgers';

    Get.dialog(
      AlertDialog(
        title: Text(item == null ? 'Add Food Item' : 'Edit Food Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: 'Image URL')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: selectedCat,
                items: ['Burgers', 'Pizza', 'Drinks', 'Desserts', 'Snacks']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => selectedCat = val!,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newItem = FoodItemModel(
                id: item?.id ?? '',
                name: nameController.text,
                price: priceController.text,
                imageUrl: imageController.text,
                category: selectedCat,
                description: descController.text,
                createdAt: item?.createdAt ?? DateTime.now(),
              );
              if (item == null) {
                controller.addFoodItem(newItem);
              } else {
                controller.updateFoodItem(newItem);
              }
              Get.back();
            },
            child: Text(item == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Food Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.deleteFoodItem(id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

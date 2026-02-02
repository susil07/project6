import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/favorites/favorites_controller.dart';
import 'package:tasty_go/presentation/pages/product_detail/product_detail_page.dart';

class FavoritesPage extends GetView<FavoritesController> {
  const FavoritesPage({super.key});

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
            'My Favorites',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.favoriteItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No favorites yet',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                ),
                itemCount: controller.favoriteItems.length,
                itemBuilder: (context, index) {
                  final item = controller.favoriteItems[index];
                  return _buildFavoriteCard(context, item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, dynamic item) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ProductDetailModal(product: item),
        );
      },
      child: Container(
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
            Expanded(
              child: Stack(
                children: [
                   ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: item.imageUrl.isEmpty
                        ? Container(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            child: Center(
                              child: Icon(Icons.fastfood, size: 40.sp, color: theme.colorScheme.primary),
                            ),
                          )
                        : Image.network(
                            item.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              child: Center(
                                child: Icon(Icons.fastfood, size: 40.sp, color: theme.colorScheme.primary),
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16.r,
                      child: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red, size: 16),
                        onPressed: () => controller.toggleFavorite(item.id),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.price,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

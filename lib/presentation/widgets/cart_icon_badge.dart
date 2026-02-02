import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/controllers/cart_controller.dart';

class CartIconBadge extends GetView<CartController> {
  const CartIconBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Obx(() {
      final count = controller.itemCount;
      
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: theme.colorScheme.onSurface),
            onPressed: () {
              Get.toNamed('/cart');
            },
          ),
          if (count > 0)
            Positioned(
              right: 6.w,
              top: 6.h,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 18.w,
                  minHeight: 18.h,
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

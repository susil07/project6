import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasty_go/data/models/food_item_model.dart';
import 'package:tasty_go/presentation/controllers/cart_controller.dart';
import 'package:tasty_go/presentation/pages/favorites/favorites_controller.dart';
import 'package:tasty_go/presentation/pages/favorites/favorites_binding.dart';

class ProductDetailModal extends StatefulWidget {
  final FoodItemModel product;

  const ProductDetailModal({super.key, required this.product});

  @override
  State<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal> {
  int quantity = 1;

  void incrementQuantity() {
    setState(() => quantity++);
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() => quantity--);
    }
  }

  void addToCart() {
    final cartController = Get.find<CartController>();
    
    // Parse price from string
    final priceString = widget.product.price.replaceAll('₹', '').trim();
    final price = double.tryParse(priceString) ?? 0.0;
    
    // Add to cart using FoodItemModel
    cartController.addToCartFromModel(
      foodItemModel: widget.product,
      price: price,
      quantity: quantity,
    );
    
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? width * 0.95 : 600,
          maxHeight: isMobile ? 650 : 700,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button and Favorite toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    final favoritesController = Get.find<FavoritesController>();
                    final isFavorite = favoritesController.isFavorite(widget.product.id);
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : theme.colorScheme.onSurface,
                      ),
                      onPressed: () => favoritesController.toggleFavorite(widget.product.id),
                    );
                  }),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            // Hero Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Hero(
                tag: 'product-${widget.product.id}',
                child: Container(
                  width: isMobile ? 200 : 280,
                  height: isMobile ? 200 : 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: widget.product.imageUrl.isEmpty
                        ? Icon(Icons.fastfood, size: isMobile ? 100 : 140, color: theme.colorScheme.primary)
                        : Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.fastfood,
                              size: isMobile ? 100 : 140,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      widget.product.name,
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price and Rating
                    Row(
                      children: [
                        Text(
                          widget.product.price,
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.green.shade700),
                              const SizedBox(width: 4),
                              Text(
                                '4.0',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      widget.product.description,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 15,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Quantity Selector
                    Row(
                      children: [
                        Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: decrementQuantity,
                                icon: const Icon(Icons.remove),
                                color: theme.colorScheme.primary,
                              ),
                              Container(
                                constraints: const BoxConstraints(minWidth: 40),
                                alignment: Alignment.center,
                                child: Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: incrementQuantity,
                                icon: const Icon(Icons.add),
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Add to Cart Button
            Container(
              padding: EdgeInsets.all(isMobile ? 20 : 24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: isMobile ? 48 : 54,
                child: ElevatedButton(
                  onPressed: addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'ADD TO CART',
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

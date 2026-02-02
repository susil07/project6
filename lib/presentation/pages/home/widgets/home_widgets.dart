import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/home/home_controller.dart';
import 'package:tasty_go/data/models/food_item_model.dart';
import 'package:tasty_go/presentation/pages/product_detail/product_detail_page.dart';

class SearchField extends GetView<HomeController> {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      onChanged: controller.onSearchChanged,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 17,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 40,
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final FoodItemModel item;

  const ProductCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Hero(
                tag: 'product-${item.id}',
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: item.imageUrl.isEmpty
                        ? Icon(Icons.fastfood, size: 40, color: theme.colorScheme.primary)
                        : Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.fastfood,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.price,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

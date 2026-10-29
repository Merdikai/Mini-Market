import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/store_provider.dart';
import '../theme/app_colors.dart';
import 'tilt_card_3d.dart';
import 'glass_container.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isFav = store.isFavorite(product.id);

    return TiltCard3D(
      maxTiltAngle: 0.18,
      perspective: 0.002,
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: 22,
        backgroundColor: AppColors.surfaceDark.withValues(alpha: 0.7),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image / Visual Display Area
            Expanded(
              child: Stack(
                children: [
                  // Product Graphic & Ambient Aura
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.85,
                        colors: [
                          product.color.withValues(alpha: 0.28),
                          AppColors.surfaceElevated.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: product.color.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        product.icon,
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Top Left Badge (e.g. LIMITED RUN)
                  if (product.badge != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.obsidian.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: product.color.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          product.badge!,
                          style: TextStyle(
                            color: product.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),

                  // Top Right Wishlist Heart Button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => store.toggleFavorite(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isFav
                                ? AppColors.errorRed.withValues(alpha: 0.5)
                                : AppColors.glassBorder,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFav ? AppColors.errorRed : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Category & Rating Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: AppColors.champagneGold),
                    const SizedBox(width: 3),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Product Title
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),

            // Price & Quick Add Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.neonCyan,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    store.addToCart(product, 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.surfaceElevated,
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: AppColors.cyberEmerald, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              '${product.title} added to bag',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: AppColors.iridescentCyanEmerald,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      size: 16,
                      color: AppColors.obsidian,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

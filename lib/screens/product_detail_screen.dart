import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/hologram_turntable.dart';
import '../widgets/glass_container.dart';
import 'add_product_screen.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedColorIndex = 0;

  final List<Color> _variants = [
    AppColors.champagneGold,
    AppColors.neonCyan,
    AppColors.cyberEmerald,
    AppColors.electricViolet,
  ];

  final List<String> _variantNames = [
    'Obsidian Gold',
    'Hyper Cyan',
    'Cyber Emerald',
    'Deep Violet',
  ];

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final product = store.getProductById(widget.productId);
    final activeColor = _variants[_selectedColorIndex];
    final isFav = store.isFavorite(product.id);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Stack(
        children: [
          // Main Scrollable Product Story
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Glass App Bar
              SliverAppBar(
                backgroundColor: AppColors.obsidian.withValues(alpha: 0.8),
                floating: true,
                pinned: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                    color: AppColors.textMuted,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppColors.errorRed : AppColors.textSecondary,
                    ),
                    onPressed: () => store.toggleFavorite(product.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddProductScreen(existingProduct: product),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                    onPressed: () {
                      store.deleteProduct(product.id);
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // 1. 3D Holographic Turntable Showcase
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: HologramTurntable(
                    icon: product.icon,
                    primaryColor: activeColor,
                    title: product.title,
                    category: product.category,
                    price: product.price,
                    size: 290,
                  ),
                ),
              ),

              // 2. Product Details & Narrative
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge & Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (product.badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: activeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: activeColor.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                product.badge!,
                                style: TextStyle(
                                  color: activeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: AppColors.champagneGold),
                              const SizedBox(width: 4),
                              Text(
                                '${product.rating} (${product.reviewCount} verified reviews)',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        product.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Narrative Description
                      Text(
                        product.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Material & Tone Finish Selector
                      const Text(
                        'FINISH & MATERIAL',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(_variants.length, (index) {
                          final isSelected = _selectedColorIndex == index;
                          final color = _variants[index];
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColorIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? color : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _variantNames[_selectedColorIndex],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Technical Specification Cards (Ora Style)
                      if (product.specs.isNotEmpty) ...[
                        const Text(
                          'TECHNICAL SPECIFICATIONS',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlassContainer(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 18,
                          backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.6),
                          child: Column(
                            children: product.specs.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      entry.value,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Glass Bottom Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassContainer(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              borderRadius: 24,
              backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.92),
              border: Border(
                top: BorderSide(
                  color: AppColors.glassBorder,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Quantity Stepper
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.glassBorder, width: 1),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                          onPressed: () {
                            if (_quantity > 1) setState(() => _quantity--);
                          },
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 16, color: Colors.white),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Add To Bag CTA Button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: AppColors.neonCyan,
                        foregroundColor: AppColors.obsidian,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        store.addToCart(product, _quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.surfaceElevated,
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: AppColors.cyberEmerald, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Added $_quantity × ${product.title} to bag',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            action: SnackBarAction(
                              label: 'VIEW BAG',
                              textColor: AppColors.neonCyan,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CartScreen()),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'ADD TO BAG • \$${(product.price * _quantity).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
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
}

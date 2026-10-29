import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponCtrl = TextEditingController();

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'YOUR BAG',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        actions: [
          if (store.cart.isNotEmpty)
            TextButton(
              onPressed: () => store.clearCart(),
              child: const Text(
                'CLEAR',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: store.cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 40,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'YOUR BAG IS EMPTY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explore our curated horology and cyber drops.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('DISCOVER ARTIFACTS'),
                  ),
                ],
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 240),
              children: [
                // Cart Items List
                ...store.cart.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(14),
                      borderRadius: 18,
                      backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.7),
                      child: Row(
                        children: [
                          // Item Thumbnail
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  item.product.color.withValues(alpha: 0.3),
                                  AppColors.surfaceDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: item.product.color.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(item.product.icon, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${item.product.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: AppColors.neonCyan,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Quantity Stepper
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.glassBorder, width: 1),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 14, color: Colors.white),
                                  onPressed: () => store.updateCartQuantity(
                                    item.product.id,
                                    item.quantity - 1,
                                  ),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 14, color: Colors.white),
                                  onPressed: () => store.updateCartQuantity(
                                    item.product.id,
                                    item.quantity + 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 10),

                // Promo Coupon Code Input
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  borderRadius: 16,
                  backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.6),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, color: AppColors.champagneGold, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _couponCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: store.activeCouponCode != null
                                ? 'APPLIED: ${store.activeCouponCode}'
                                : 'ENTER PROMO (e.g. ORA20, VIP50)',
                            hintStyle: TextStyle(
                              color: store.activeCouponCode != null ? AppColors.cyberEmerald : AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final success = store.applyCoupon(_couponCtrl.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.surfaceDark,
                              content: Text(
                                success
                                    ? '✨ Promo activated: ${(store.appliedDiscount * 100).toInt()}% off!'
                                    : 'Invalid code. Try "ORA20" or "ARTEFAKT"',
                                style: TextStyle(
                                  color: success ? AppColors.cyberEmerald : AppColors.errorRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                          _couponCtrl.clear();
                        },
                        child: const Text(
                          'APPLY',
                          style: TextStyle(
                            color: AppColors.neonCyan,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

      // Bottom Checkout Drawer
      bottomSheet: store.cart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                border: const Border(
                  top: BorderSide(color: AppColors.glassBorder, width: 1.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text('\$${store.cartSubtotal.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (store.appliedDiscount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('VIP Discount (${(store.appliedDiscount * 100).toInt()}%)',
                            style: const TextStyle(color: AppColors.cyberEmerald, fontSize: 13)),
                        Text('-\$${(store.cartSubtotal * store.appliedDiscount).toStringAsFixed(0)}',
                            style: const TextStyle(color: AppColors.cyberEmerald, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Complimentary Shipping', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text('FREE', style: TextStyle(color: AppColors.cyberEmerald, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: AppColors.glassBorder, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '\$${store.cartTotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonCyan,
                        foregroundColor: AppColors.obsidian,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'PROCEED TO CHECKOUT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

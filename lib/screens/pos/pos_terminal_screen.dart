import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/retail_cached_image.dart';
import '../../widgets/status_badge.dart';
import 'held_orders_screen.dart';
import 'pos_payment_modal.dart';
import 'refund_screen.dart';

class POSTerminalScreen extends StatefulWidget {
  const POSTerminalScreen({super.key});

  @override
  State<POSTerminalScreen> createState() => _POSTerminalScreenState();
}

class _POSTerminalScreenState extends State<POSTerminalScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openBarcodeScanner(BuildContext context, StoreProvider store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = AppTheme.isDark(ctx);
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Barcode Scanner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Camera optical viewport mockup
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 80,
                      color: (isDark ? AppColors.neonCyan : AppColors.brandPrimary).withValues(alpha: 0.5),
                    ),
                    Positioned(
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Point optical laser at retail barcode',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'QUICK SCAN SHORTCUTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: store.products.take(6).map((p) {
                  return ActionChip(
                    avatar: const Icon(Icons.barcode_reader, size: 16),
                    label: Text('${p.title} (${p.barcode})'),
                    onPressed: () {
                      store.addToCart(p);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Scanned: ${p.title} added to cart.'),
                          backgroundColor: AppColors.stockGreen,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPaymentModal(BuildContext context) {
    final store = context.read<StoreProvider>();
    if (store.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items to cart before proceeding to checkout.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const POSPaymentModal(),
    );
  }

  void _showHoldCartDialog(BuildContext context, StoreProvider store) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Hold Current Cart'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Customer or Identifier',
              hintText: 'e.g. Table 4 / Blue Jacket Customer',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                store.holdCart(controller.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cart held. Terminal ready for next customer.'),
                    backgroundColor: AppColors.alertOrange,
                  ),
                );
              },
              child: const Text('Hold Cart'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);
    final products = store.filteredProducts;

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // POS Top Bar
            _buildTopBar(context, store, isDark),

            // Category Chips Row
            _buildCategorySelector(store, isDark),

            // Products Grid View
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No products match your criteria.',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 90),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.74,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductCard(context, store, product, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
      // Sticky POS Cart Bottom Bar
      bottomSheet: _buildCartBottomBar(context, store, isDark),
    );
  }

  Widget _buildTopBar(BuildContext context, StoreProvider store, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Store & Cashier Identity
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isDark ? AppColors.neonCyan.withValues(alpha: 0.15) : AppColors.brandPrimary.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.person_rounded,
                        size: 20,
                        color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.currentStaff?.name ?? 'Alex Rivera',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                          ),
                        ),
                        Row(
                          children: [
                            StatusBadge.shift(store.activeShift?.status ?? ShiftStatus.open),
                            const SizedBox(width: 6),
                            Text(
                              'Shift: ${CurrencyFormatter.format(store.activeShift?.openingFloat ?? 150.0, store.settings.currencySymbol)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Held Orders Quick Badge
              if (store.heldCarts.isNotEmpty)
                IconButton(
                  icon: Badge(
                    label: Text('${store.heldCarts.length}'),
                    backgroundColor: AppColors.alertOrange,
                    child: const Icon(Icons.pause_circle_rounded),
                  ),
                  tooltip: 'Parked Orders',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HeldOrdersScreen()),
                    );
                  },
                ),

              // Returns & Refunds
              IconButton(
                icon: const Icon(Icons.replay_rounded),
                tooltip: 'Process Return',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RefundScreen()),
                  );
                },
              ),

              // Barcode Scanner Action
              IconButton(
                icon: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                ),
                tooltip: 'Scan Barcode',
                onPressed: () => _openBarcodeScanner(context, store),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Search Field
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: store.setSearchQuery,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: 'Search title, SKU or scan barcode...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          store.setSearchQuery('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(StoreProvider store, bool isDark) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: store.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = store.categories[index];
          final isSelected = store.selectedCategory == cat;

          return FilterChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (_) => store.setSelectedCategory(cat),
            selectedColor: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? (isDark ? AppColors.obsidian : Colors.white)
                  : (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : (isDark ? AppColors.glassBorder : AppColors.lightBorder),
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    StoreProvider store,
    Product product,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        store.addToCart(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.title} added to cart'),
            duration: const Duration(milliseconds: 600),
            backgroundColor: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Real Internet Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: RetailProductImage(
                    imageUrl: product.imageUrl,
                    width: double.infinity,
                    height: 110,
                    fallbackIcon: product.icon,
                    fallbackColor: product.color,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: StatusBadge.stock(product.stock, product.minStock),
                ),
                if (product.badge != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Card Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${product.sku} • ${product.unit}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CurrencyFormatter.format(product.price, store.settings.currencySymbol),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            size: 16,
                            color: isDark ? AppColors.obsidian : Colors.white,
                          ),
                        ),
                      ],
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

  Widget _buildCartBottomBar(
    BuildContext context,
    StoreProvider store,
    bool isDark,
  ) {
    final count = store.cartItemCount;
    final total = store.cartTotal;

    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevated : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quick Cart Drawer Button
          InkWell(
            onTap: () => _showCartDrawer(context, store, isDark),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.lightSurfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag_rounded, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '$count items',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_up_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Total & Charge Button
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _openPaymentModal(context),
                icon: const Icon(Icons.payments_rounded, size: 18),
                label: Text(
                  'Charge ${CurrencyFormatter.format(total, store.settings.currencySymbol)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCartDrawer(BuildContext context, StoreProvider store, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final cart = store.cart;
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Register Cart (${store.cartItemCount})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.pause_circle_outline_rounded, color: AppColors.alertOrange),
                            tooltip: 'Hold Cart',
                            onPressed: () {
                              Navigator.pop(ctx);
                              _showHoldCartDialog(context, store);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed),
                            tooltip: 'Clear Cart',
                            onPressed: () {
                              store.clearCart();
                              Navigator.pop(ctx);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),

                  // Cart Line Items List
                  Expanded(
                    child: cart.isEmpty
                        ? const Center(child: Text('Cart is empty'))
                        : ListView.separated(
                            itemCount: cart.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (c, i) {
                              final item = cart[i];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    RetailProductImage(
                                      imageUrl: item.product.imageUrl,
                                      width: 44,
                                      height: 44,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                            ),
                                          ),
                                          Text(
                                            '${CurrencyFormatter.format(item.product.price, store.settings.currencySymbol)} / ${item.product.unit}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline, size: 18),
                                          onPressed: () {
                                            store.updateCartQuantity(item.product.id, item.quantity - 1);
                                            setModalState(() {});
                                          },
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.w800),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline, size: 18),
                                          onPressed: () {
                                            store.updateCartQuantity(item.product.id, item.quantity + 1);
                                            setModalState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        CurrencyFormatter.format(item.total, store.settings.currencySymbol),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  // Cart Totals Summary
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text(CurrencyFormatter.format(store.cartSubtotal, store.settings.currencySymbol)),
                      ],
                    ),
                  ),
                  if (store.cartDiscountAmount > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Discount:', style: TextStyle(color: AppColors.stockGreen)),
                          Text('-${CurrencyFormatter.format(store.cartDiscountAmount, store.settings.currencySymbol)}', style: const TextStyle(color: AppColors.stockGreen)),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tax (${(store.settings.taxRate * 100).toStringAsFixed(0)}%):'),
                        Text(CurrencyFormatter.format(store.cartTaxAmount, store.settings.currencySymbol)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL DUE:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          CurrencyFormatter.format(store.cartTotal, store.settings.currencySymbol),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Proceed to Pay
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openPaymentModal(context);
                      },
                      child: Text('Tender Payment (${CurrencyFormatter.format(store.cartTotal, store.settings.currencySymbol)})'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

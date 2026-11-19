import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/retail_cached_image.dart';
import '../../widgets/search_and_filter_bar.dart';
import '../../widgets/status_badge.dart';
import 'add_edit_product_screen.dart';
import 'damaged_goods_screen.dart';
import 'inventory_ledger_screen.dart';
import 'stocktake_audit_screen.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedStockTab = 0; // 0 = All, 1 = Low Stock, 2 = Out of Stock

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showQuickAdjustDialog(BuildContext context, StoreProvider store, Product product) {
    final countController = TextEditingController(text: product.stock.toString());
    final reasonController = TextEditingController(text: 'Spot physical recount');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Adjust Stock: ${product.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'New On-Hand Stock (${product.unit})',
                  prefixIcon: const Icon(Icons.storage_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason for Adjustment'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newCount = int.tryParse(countController.text) ?? product.stock;
                store.adjustStock(product.id, newCount, reason: reasonController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated ${product.title} stock to $newCount.'),
                    backgroundColor: AppColors.stockGreen,
                  ),
                );
              },
              child: const Text('Save Count'),
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

    // Apply search and category filter
    List<Product> products = store.filteredProducts;

    // Apply stock status tab
    if (_selectedStockTab == 1) {
      products = products.where((p) => p.isLowStock).toList();
    } else if (_selectedStockTab == 2) {
      products = products.where((p) => p.isOutOfStock).toList();
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Inventory & Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu_rounded),
            tooltip: 'Stock Movement Ledger',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryLedgerScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.fact_check_rounded),
            tooltip: 'Stocktake Audit',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StocktakeAuditScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // KPI Summary Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildKpiItem('TOTAL ITEMS', '${store.products.length}', isDark),
                  _buildKpiItem('LOW STOCK', '${store.lowStockProducts.length}', isDark, color: AppColors.alertOrange),
                  _buildKpiItem(
                    'RETAIL VALUE',
                    CurrencyFormatter.formatCompact(store.totalInventoryRetailValue, store.settings.currencySymbol),
                    isDark,
                    color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SearchAndFilterBar(
                controller: _searchController,
                onChanged: store.setSearchQuery,
              ),
            ),

            // Category Chips Selector
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  );
                },
              ),
            ),
            const SizedBox(height: 6),

            // Stock Status Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _buildStockTab('All Products (${store.products.length})', 0, isDark),
                  const SizedBox(width: 8),
                  _buildStockTab('Low Stock (${store.lowStockProducts.where((p) => p.isLowStock).length})', 1, isDark),
                  const SizedBox(width: 8),
                  _buildStockTab('Out of Stock (${store.lowStockProducts.where((p) => p.isOutOfStock).length})', 2, isDark),
                ],
              ),
            ),
            const Divider(height: 12),

            // Product Cards List
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Text(
                        'No products match the selected criteria.',
                        style: TextStyle(
                          color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                      itemCount: products.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              RetailProductImage(
                                imageUrl: product.imageUrl,
                                width: 58,
                                height: 58,
                                fallbackIcon: product.icon,
                                fallbackColor: product.color,
                              ),
                              const SizedBox(width: 12),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            product.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        StatusBadge.stock(product.stock, product.minStock),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${product.sku} • Barcode: ${product.barcode}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          CurrencyFormatter.format(product.price, store.settings.currencySymbol),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Cost: ${CurrencyFormatter.format(product.costPrice, store.settings.currencySymbol)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.stockGreen.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${product.marginPercentage.toStringAsFixed(0)}% margin',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.stockGreen,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Action Menu
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded),
                                onSelected: (action) {
                                  if (action == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddEditProductScreen(productToEdit: product),
                                      ),
                                    );
                                  } else if (action == 'adjust') {
                                    _showQuickAdjustDialog(context, store, product);
                                  } else if (action == 'waste') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const DamagedGoodsScreen()),
                                    );
                                  } else if (action == 'delete') {
                                    store.deleteProduct(product.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${product.title} removed from catalog.')),
                                    );
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit Product'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'adjust',
                                    child: Row(
                                      children: [
                                        Icon(Icons.tune_rounded, size: 18),
                                        SizedBox(width: 8),
                                        Text('Adjust Count'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'waste',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_sweep_outlined, size: 18, color: AppColors.errorRed),
                                        SizedBox(width: 8),
                                        Text('Log Waste / Damage', style: TextStyle(color: AppColors.errorRed)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, size: 18, color: AppColors.errorRed),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: AppColors.errorRed)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildKpiItem(String label, String value, bool isDark, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color ?? (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
          ),
        ),
      ],
    );
  }

  Widget _buildStockTab(String label, int index, bool isDark) {
    final isSelected = _selectedStockTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedStockTab = index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? (isDark ? AppColors.neonCyan : AppColors.brandPrimary)
                : (isDark ? AppColors.textMuted : AppColors.textMutedLight),
          ),
        ),
      ),
    );
  }
}

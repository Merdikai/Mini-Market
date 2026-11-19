import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/retail_cached_image.dart';

class StocktakeAuditScreen extends StatefulWidget {
  const StocktakeAuditScreen({super.key});

  @override
  State<StocktakeAuditScreen> createState() => _StocktakeAuditScreenState();
}

class _StocktakeAuditScreenState extends State<StocktakeAuditScreen> {
  final Map<String, int> _countedCounts = {};

  @override
  void initState() {
    super.initState();
    final store = context.read<StoreProvider>();
    for (final p in store.products) {
      _countedCounts[p.id] = p.stock;
    }
  }

  void _reconcileAll(StoreProvider store) {
    int adjustedCount = 0;
    for (final entry in _countedCounts.entries) {
      final p = store.getProductById(entry.key);
      if (p.stock != entry.value) {
        store.adjustStock(
          p.id,
          entry.value,
          reason: 'Physical Stocktake Count Reconciled',
        );
        adjustedCount++;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reconciled $adjustedCount product stock discrepancies.'),
        backgroundColor: AppColors.stockGreen,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);
    final products = store.products;

    // Calculate total variance
    int totalUnitVariance = 0;
    double totalValueVariance = 0.0;

    for (final p in products) {
      final counted = _countedCounts[p.id] ?? p.stock;
      final diff = counted - p.stock;
      totalUnitVariance += diff;
      totalValueVariance += diff * p.costPrice;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Stocktake & Physical Count Audit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_rounded),
            tooltip: 'Apply Reconciliation',
            onPressed: () => _reconcileAll(store),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Discrepancy Summary Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('NET UNIT VARIANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      Text(
                        totalUnitVariance == 0
                            ? '0 pcs'
                            : (totalUnitVariance > 0 ? '+$totalUnitVariance pcs' : '$totalUnitVariance pcs'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: totalUnitVariance == 0 ? AppColors.stockGreen : (totalUnitVariance > 0 ? AppColors.neonCyan : AppColors.errorRed),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('COST VALUE VARIANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      Text(
                        CurrencyFormatter.format(totalValueVariance, store.settings.currencySymbol),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: totalValueVariance >= 0 ? AppColors.stockGreen : AppColors.errorRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Products Count Sheet List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: products.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final p = products[index];
                  final counted = _countedCounts[p.id] ?? p.stock;
                  final diff = counted - p.stock;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: diff != 0
                            ? AppColors.alertOrange
                            : (isDark ? AppColors.glassBorder : AppColors.lightBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        RetailProductImage(imageUrl: p.imageUrl, width: 44, height: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.title,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              Text(
                                '${p.sku} • System Stock: ${p.stock} ${p.unit}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                                ),
                              ),
                              if (diff != 0)
                                Text(
                                  diff > 0 ? '+$diff surplus' : '$diff shortage',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: diff > 0 ? AppColors.neonCyan : AppColors.errorRed,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Counter Stepper
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                              onPressed: () {
                                if (counted > 0) {
                                  setState(() {
                                    _countedCounts[p.id] = counted - 1;
                                  });
                                }
                              },
                            ),
                            Container(
                              width: 44,
                              alignment: Alignment.center,
                              child: Text(
                                '$counted',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              onPressed: () {
                                setState(() {
                                  _countedCounts[p.id] = counted + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Reconcile Action Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _reconcileAll(store),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('Apply Reconciled Counts to Inventory'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

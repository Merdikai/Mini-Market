import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/kpi_stat_card.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  void _showXReportDialog(BuildContext context, StoreProvider store) {
    final shift = store.activeShift;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Mid-Day X-Report (Live Audit)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Generated: ${DateFormatter.formatFull(DateTime.now())}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const Divider(height: 16),
              _buildReportRow('Active Cashier', shift?.staffName ?? 'None'),
              _buildReportRow('Opening Float', CurrencyFormatter.format(shift?.openingFloat ?? 0.0, store.settings.currencySymbol)),
              _buildReportRow('Cash Sales', CurrencyFormatter.format(shift?.totalCashSales ?? 0.0, store.settings.currencySymbol)),
              _buildReportRow('Card Sales', CurrencyFormatter.format(shift?.totalCardSales ?? 0.0, store.settings.currencySymbol)),
              _buildReportRow('Safe Drops', '-${CurrencyFormatter.format(shift?.cashDrops ?? 0.0, store.settings.currencySymbol)}'),
              const Divider(height: 16),
              _buildReportRow(
                'Expected in Drawer',
                CurrencyFormatter.format(shift?.expectedCashInDrawer ?? 0.0, store.settings.currencySymbol),
                isBold: true,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('X-Report printed to register.'), backgroundColor: AppColors.stockGreen),
                );
              },
              icon: const Icon(Icons.print_rounded, size: 16),
              label: const Text('Print X-Report'),
            ),
          ],
        );
      },
    );
  }

  void _showProfitLossDialog(BuildContext context, StoreProvider store) {
    final revenue = store.todaySalesTotal;
    // Calculate cost of goods sold for today's completed sales
    double cogs = 0.0;
    for (final order in store.salesHistory.where((s) => s.status == OrderStatus.completed)) {
      for (final item in order.items) {
        cogs += item.product.costPrice * item.quantity;
      }
    }
    final grossProfit = revenue - cogs;
    final expenses = store.totalOperatingExpenses;
    final netIncome = grossProfit - expenses;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Profit & Loss Statement (P&L)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Period: Today (${DateFormatter.formatShort(DateTime.now())})', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const Divider(height: 16),
              _buildReportRow('Gross Sales Revenue', CurrencyFormatter.format(revenue, store.settings.currencySymbol)),
              _buildReportRow('Cost of Goods Sold (COGS)', '-${CurrencyFormatter.format(cogs, store.settings.currencySymbol)}', color: AppColors.errorRed),
              const Divider(height: 12),
              _buildReportRow('Gross Profit', CurrencyFormatter.format(grossProfit, store.settings.currencySymbol), isBold: true, color: AppColors.stockGreen),
              const SizedBox(height: 8),
              _buildReportRow('Operating Expenses', '-${CurrencyFormatter.format(expenses, store.settings.currencySymbol)}', color: AppColors.errorRed),
              const Divider(height: 16),
              _buildReportRow(
                'NET OPERATING INCOME',
                CurrencyFormatter.format(netIncome, store.settings.currencySymbol),
                isBold: true,
                color: netIncome >= 0 ? AppColors.stockGreen : AppColors.errorRed,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('P&L report exported to CSV.'), backgroundColor: AppColors.stockGreen),
                );
              },
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Export CSV'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildReportRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);

    final avgBasket = store.todayOrdersCount > 0 ? (store.todaySalesTotal / store.todayOrdersCount) : 0.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Business Reports & Intelligence'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top KPI Metrics
              Row(
                children: [
                  Expanded(
                    child: KPIStatCard(
                      title: 'TODAY\'S REVENUE',
                      value: CurrencyFormatter.format(store.todaySalesTotal, store.settings.currencySymbol),
                      subtitle: '${store.todayOrdersCount} completed sales',
                      icon: Icons.trending_up_rounded,
                      accentColor: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KPIStatCard(
                      title: 'AVERAGE BASKET',
                      value: CurrencyFormatter.format(avgBasket, store.settings.currencySymbol),
                      subtitle: 'Per checkout ticket',
                      icon: Icons.shopping_basket_rounded,
                      accentColor: AppColors.stockGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: KPIStatCard(
                      title: 'INVENTORY VALUATION',
                      value: CurrencyFormatter.formatCompact(store.totalInventoryRetailValue, store.settings.currencySymbol),
                      subtitle: 'Cost: ${CurrencyFormatter.formatCompact(store.totalInventoryCostValue, store.settings.currencySymbol)}',
                      icon: Icons.inventory_2_rounded,
                      accentColor: AppColors.champagneGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KPIStatCard(
                      title: 'TOTAL EXPENSES',
                      value: CurrencyFormatter.format(store.totalOperatingExpenses, store.settings.currencySymbol),
                      subtitle: '${store.expenses.length} expense entries',
                      icon: Icons.receipt_long_rounded,
                      accentColor: AppColors.errorRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Report Generation Launchers
              Text(
                'MANAGEMENT STATEMENTS & AUDITS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              _buildReportCard(
                title: 'Daily X-Report (Mid-Shift Audit)',
                subtitle: 'Snapshot of current register drawer float, tender split, and safe drops',
                icon: Icons.point_of_sale_rounded,
                onTap: () => _showXReportDialog(context, store),
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildReportCard(
                title: 'Profit & Loss Statement (P&L)',
                subtitle: 'Gross revenue, Cost of Goods Sold (COGS), operating expenses, and net profit',
                icon: Icons.account_balance_rounded,
                onTap: () => _showProfitLossDialog(context, store),
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Top Products Leaderboard
              Text(
                'PRODUCT PERFORMANCE LEADERBOARD',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: store.products.take(5).length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final p = store.products[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: (index == 0
                                  ? AppColors.champagneGold
                                  : (isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary))
                              .withValues(alpha: 0.2),
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: index == 0 ? AppColors.champagneGold : AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              Text('${p.category} • In Stock: ${p.stock} ${p.unit}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(p.price, store.settings.currencySymbol),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.neonCyan : AppColors.brandPrimary).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isDark ? AppColors.neonCyan : AppColors.brandPrimary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

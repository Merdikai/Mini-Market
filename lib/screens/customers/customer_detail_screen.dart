import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/customer.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/kpi_stat_card.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  void _redeemPointsDialog(BuildContext context, StoreProvider store) {
    if (customer.loyaltyPoints < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 100 loyalty points required for voucher redemption.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Redeem Loyalty Points'),
          content: Text(
            'Redeem 100 points for a \$5.00 store credit voucher added directly to ${customer.name}\'s balance? (Current: ${customer.loyaltyPoints} pts)',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                customer.loyaltyPoints -= 100;
                store.addStoreCredit(customer.id, 5.00);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Redeemed 100 points! \$5.00 credited to account.'),
                    backgroundColor: AppColors.stockGreen,
                  ),
                );
              },
              child: const Text('Redeem 100 Pts (+\$5.00)'),
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

    // Filter past orders for this customer
    final customerOrders = store.salesHistory.where((o) => o.customerName == customer.name || o.customerId == customer.id).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: Text(customer.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Summary Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: isDark ? AppColors.neonCyan.withValues(alpha: 0.15) : AppColors.brandPrimary.withValues(alpha: 0.12),
                          child: Icon(
                            Icons.person_rounded,
                            size: 32,
                            color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                ),
                              ),
                              Text(
                                customer.phone,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                ),
                              ),
                              if (customer.email.isNotEmpty)
                                Text(
                                  customer.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (customer.notes.isNotEmpty) ...[
                      const Divider(height: 20),
                      Text(
                        'Note: ${customer.notes}',
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // KPI Cards: Points & Store Credit
              Row(
                children: [
                  Expanded(
                    child: KPIStatCard(
                      title: 'LOYALTY POINTS',
                      value: '${customer.loyaltyPoints} pts',
                      subtitle: '1 pt per \$1 spent',
                      icon: Icons.star_rounded,
                      accentColor: AppColors.champagneGold,
                      onTap: () => _redeemPointsDialog(context, store),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KPIStatCard(
                      title: 'STORE CREDIT',
                      value: CurrencyFormatter.format(customer.storeCredit, store.settings.currencySymbol),
                      subtitle: '${customer.visitCount} lifetime visits',
                      icon: Icons.account_balance_wallet_rounded,
                      accentColor: AppColors.stockGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Transaction / Order History
              Text(
                'PURCHASE HISTORY (${customerOrders.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              if (customerOrders.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('No past purchases recorded for this customer yet.', style: TextStyle(color: AppColors.textMuted)),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: customerOrders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final o = customerOrders[index];
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(o.orderNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(DateFormatter.formatRelative(o.timestamp), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                          Text(
                            CurrencyFormatter.format(o.total, store.settings.currencySymbol),
                            style: TextStyle(
                              fontSize: 15,
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
}

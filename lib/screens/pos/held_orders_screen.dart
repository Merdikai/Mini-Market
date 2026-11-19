import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class HeldOrdersScreen extends StatelessWidget {
  const HeldOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);
    final heldCarts = store.heldCarts;

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Parked & Held Orders'),
      ),
      body: SafeArea(
        child: heldCarts.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pause_circle_outline_rounded,
                      size: 64,
                      color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Held Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Park active carts during customer pauses or queues.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: heldCarts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final held = heldCarts[index];
                  final total = held.items.fold(0.0, (sum, i) => sum + i.total) - held.discount;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.alertOrange.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.pause_rounded,
                                    size: 16,
                                    color: AppColors.alertOrange,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  held.customerName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              CurrencyFormatter.format(total, store.settings.currencySymbol),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${held.items.length} unique items (${held.items.fold(0, (s, i) => s + i.quantity)} total pcs)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Held ${DateFormatter.formatRelative(held.heldAt)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  store.discardHeldCart(held.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Held cart removed.')),
                                  );
                                },
                                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.errorRed),
                                label: const Text('Discard', style: TextStyle(color: AppColors.errorRed)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.errorRed),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  store.recallHeldCart(held);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Cart restored to POS terminal.'),
                                      backgroundColor: AppColors.stockGreen,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.restore_rounded, size: 16),
                                label: const Text('Recall to Register'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
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
    );
  }
}

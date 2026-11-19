import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class ShiftManagementScreen extends StatelessWidget {
  const ShiftManagementScreen({super.key});

  void _showOpenShiftDialog(BuildContext context, StoreProvider store) {
    final floatController = TextEditingController(text: '150.00');
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Open Register Shift'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: floatController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Opening Cash Float (\$)',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Shift Notes (Optional)',
                  hintText: 'e.g. Verified \$150 in coin and bills',
                ),
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
                final amount = double.tryParse(floatController.text) ?? 150.0;
                store.openShift(amount, notes: notesController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shift opened successfully.'),
                    backgroundColor: AppColors.stockGreen,
                  ),
                );
              },
              child: const Text('Open Shift'),
            ),
          ],
        );
      },
    );
  }

  void _showSafeDropDialog(BuildContext context, StoreProvider store) {
    final amountController = TextEditingController();
    final reasonController = TextEditingController(text: 'Excess cash to safe');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Register Safe Drop'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Drop Amount (\$)',
                  prefixIcon: Icon(Icons.arrow_downward_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                ),
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
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount > 0) {
                  store.recordCashDrop(amount, reasonController.text.trim());
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Safe drop of \$${amount.toStringAsFixed(2)} recorded.'),
                      backgroundColor: AppColors.alertOrange,
                    ),
                  );
                }
              },
              child: const Text('Confirm Drop'),
            ),
          ],
        );
      },
    );
  }

  void _showCloseShiftDialog(BuildContext context, StoreProvider store) {
    final countController = TextEditingController();
    final notesController = TextEditingController();
    final expected = store.activeShift?.expectedCashInDrawer ?? 0.0;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Close Shift & Drawer Reconciliation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expected Cash in Drawer: ${CurrencyFormatter.format(expected, store.settings.currencySymbol)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: countController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Actual Counted Cash (\$)',
                    prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Closing Notes / Discrepancy Reason',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final counted = double.tryParse(countController.text) ?? expected;
                store.closeShift(counted, notes: notesController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shift closed and drawer reconciled.'),
                    backgroundColor: AppColors.stockGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
              child: const Text('Close Register Shift'),
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
    final activeShift = store.activeShift;

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Cashier Shifts & Drawer Control'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Shift Card
              if (activeShift != null) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.neonCyan.withValues(alpha: 0.4) : AppColors.brandPrimary.withValues(alpha: 0.3),
                      width: 1.5,
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
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: isDark ? AppColors.neonCyan.withValues(alpha: 0.15) : AppColors.brandPrimary.withValues(alpha: 0.12),
                                child: Icon(
                                  Icons.lock_open_rounded,
                                  size: 18,
                                  color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeShift.staffName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  Text(
                                    'Opened ${DateFormatter.formatRelative(activeShift.openedAt)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          StatusBadge.shift(ShiftStatus.open),
                        ],
                      ),
                      const Divider(height: 24),

                      // Metric Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricItem(
                              'STARTING FLOAT',
                              CurrencyFormatter.format(activeShift.openingFloat, store.settings.currencySymbol),
                              isDark,
                            ),
                          ),
                          Expanded(
                            child: _buildMetricItem(
                              'CASH SALES',
                              CurrencyFormatter.format(activeShift.totalCashSales, store.settings.currencySymbol),
                              isDark,
                              color: AppColors.stockGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricItem(
                              'CARD / POS SALES',
                              CurrencyFormatter.format(activeShift.totalCardSales, store.settings.currencySymbol),
                              isDark,
                            ),
                          ),
                          Expanded(
                            child: _buildMetricItem(
                              'SAFE DROPS',
                              '-${CurrencyFormatter.format(activeShift.cashDrops, store.settings.currencySymbol)}',
                              isDark,
                              color: AppColors.alertOrange,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Expected Cash in Drawer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'EXPECTED IN DRAWER:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(activeShift.expectedCashInDrawer, store.settings.currencySymbol),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showSafeDropDialog(context, store),
                              icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                              label: const Text('Safe Drop'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showCloseShiftDialog(context, store),
                              icon: const Icon(Icons.lock_rounded, size: 16),
                              label: const Text('Close Shift'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorRed,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Register is closed
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.lock_outline_rounded, size: 54, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'Register Shift is Closed',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Open a shift with cash float to enable cashier transactions.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () => _showOpenShiftDialog(context, store),
                        icon: const Icon(Icons.lock_open_rounded, size: 18),
                        label: const Text('Open Register Shift'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // Shift History Log
              Text(
                'SHIFT RECONCILIATION HISTORY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              if (store.shiftHistory.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('No past shifts recorded yet.', style: TextStyle(color: AppColors.textMuted)),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: store.shiftHistory.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final shift = store.shiftHistory[index];
                    final disc = shift.cashDiscrepancy;

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
                              Text(
                                shift.staffName,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Closed ${DateFormatter.formatRelative(shift.closedAt ?? DateTime.now())}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Counted: ${CurrencyFormatter.format(shift.actualCashCounted ?? 0.0, store.settings.currencySymbol)}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              Text(
                                disc == 0.0
                                    ? 'Balanced (±\$0.00)'
                                    : (disc > 0 ? '+\$${disc.toStringAsFixed(2)} Overage' : '-\$${disc.abs().toStringAsFixed(2)} Shortage'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: disc == 0.0
                                      ? AppColors.stockGreen
                                      : (disc > 0 ? AppColors.neonCyan : AppColors.errorRed),
                                ),
                              ),
                            ],
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

  Widget _buildMetricItem(String label, String value, bool isDark, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color ?? (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
          ),
        ),
      ],
    );
  }
}

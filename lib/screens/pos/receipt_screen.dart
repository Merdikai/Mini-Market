import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sale_order.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/thermal_receipt_preview.dart';

class ReceiptScreen extends StatelessWidget {
  final SaleOrder order;

  const ReceiptScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Transaction Receipt'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded),
            tooltip: 'Print',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sent print job to 80mm thermal receipt printer.'),
                  backgroundColor: AppColors.stockGreen,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                // Thermal Receipt Preview
                ThermalReceiptPreview(
                  order: order,
                  settings: store.settings,
                  onPrint: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Printing thermal receipt...'),
                        backgroundColor: AppColors.stockGreen,
                      ),
                    );
                  },
                  onShare: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Receipt #${order.orderNumber} exported as PDF.'),
                        backgroundColor: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Return to Terminal Action Button
                SizedBox(
                  width: 320,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.point_of_sale_rounded, size: 18),
                    label: const Text('New Sale / Return to POS'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

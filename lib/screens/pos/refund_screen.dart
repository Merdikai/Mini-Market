import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/sale_order.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class RefundScreen extends StatefulWidget {
  const RefundScreen({super.key});

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final TextEditingController _reasonController = TextEditingController(text: 'Customer item return / defective');

  @override
  void dispose() {
    _searchController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);

    final filteredOrders = store.salesHistory.where((o) {
      if (_query.isEmpty) return true;
      return o.orderNumber.toLowerCase().contains(_query.toLowerCase()) ||
          (o.customerName?.toLowerCase().contains(_query.toLowerCase()) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Returns & Refunds'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Order Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _query = val),
                decoration: InputDecoration(
                  hintText: 'Search order by invoice # or customer...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Order List or Details
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(
                      child: Text(
                        'No matching orders found.',
                        style: TextStyle(
                          color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredOrders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        final isRefunded = order.status == OrderStatus.refunded;

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
                                  Text(
                                    order.orderNumber,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  StatusBadge.order(order.status),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${order.customerName ?? "Walk-in"} • ${DateFormatter.formatRelative(order.timestamp)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${order.items.length} items: ${order.items.map((i) => "${i.quantity}x ${i.product.title}").join(", ")}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total: ${CurrencyFormatter.format(order.total, store.settings.currencySymbol)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  if (!isRefunded)
                                    ElevatedButton.icon(
                                      onPressed: () => _confirmRefundDialog(context, store, order),
                                      icon: const Icon(Icons.replay_rounded, size: 16),
                                      label: const Text('Process Refund'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.errorRed,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
    );
  }

  void _confirmRefundDialog(BuildContext context, StoreProvider store, SaleOrder order) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Refund ${order.orderNumber}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will mark the order as refunded, return ${order.totalItemCount} items into active store inventory, and record an audit ledger entry.',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Refund Reason',
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
                store.processRefund(order.id, reason: _reasonController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Refund processed for ${order.orderNumber}. Inventory restocked.'),
                    backgroundColor: AppColors.stockGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Refund'),
            ),
          ],
        );
      },
    );
  }
}

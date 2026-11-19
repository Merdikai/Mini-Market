import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/purchase_order.dart';
import '../../models/supplier.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  PurchaseOrderStatus? _filterStatus;

  void _showCreatePODialog(BuildContext context, StoreProvider store) {
    if (store.suppliers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please register at least one supplier first.')),
      );
      return;
    }

    Supplier selectedSupplier = store.suppliers.first;
    final List<PurchaseOrderItem> orderItems = [];

    // Pre-populate with first product for convenience
    if (store.products.isNotEmpty) {
      final p = store.products.first;
      orderItems.add(
        PurchaseOrderItem(
          productId: p.id,
          productTitle: p.title,
          quantityOrdered: 24,
          unitCost: p.costPrice,
        ),
      );
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final poTotal = orderItems.fold(0.0, (sum, i) => sum + i.lineTotal);

            return AlertDialog(
              title: const Text('New Purchase Order (PO)'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<Supplier>(
                      initialValue: selectedSupplier,
                      decoration: const InputDecoration(labelText: 'Supplier'),
                      items: store.suppliers.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s.companyName));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedSupplier = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'ORDERED LINE ITEMS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 6),
                    ...orderItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.productTitle,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ),
                            Text('${item.quantityOrdered} pcs @ \$${item.unitCost.toStringAsFixed(2)}'),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    // Quick add line item
                    OutlinedButton.icon(
                      onPressed: () {
                        if (store.products.length > orderItems.length) {
                          final nextP = store.products[orderItems.length];
                          setDialogState(() {
                            orderItems.add(
                              PurchaseOrderItem(
                                productId: nextP.id,
                                productTitle: nextP.title,
                                quantityOrdered: 20,
                                unitCost: nextP.costPrice,
                              ),
                            );
                          });
                        }
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Product to Order'),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ESTIMATED TOTAL:', style: TextStyle(fontWeight: FontWeight.w800)),
                        Text(
                          CurrencyFormatter.format(poTotal, store.settings.currencySymbol),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ],
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
                    if (orderItems.isNotEmpty) {
                      final poNumber = 'PO-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}-${(store.purchaseOrders.length + 101)}';
                      final po = PurchaseOrder(
                        id: 'po_${DateTime.now().millisecondsSinceEpoch}',
                        orderNumber: poNumber,
                        supplierId: selectedSupplier.id,
                        supplierName: selectedSupplier.companyName,
                        orderDate: DateTime.now(),
                        expectedDelivery: DateTime.now().add(const Duration(days: 3)),
                        items: List.from(orderItems),
                        status: PurchaseOrderStatus.submitted,
                      );
                      store.createPurchaseOrder(po);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Purchase order $poNumber issued to ${selectedSupplier.companyName}.'),
                          backgroundColor: AppColors.stockGreen,
                        ),
                      );
                    }
                  },
                  child: const Text('Issue PO'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);

    final orders = store.purchaseOrders.where((po) {
      if (_filterStatus == null) return true;
      return po.status == _filterStatus;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Purchase Orders & Restock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add_rounded),
            tooltip: 'Create PO',
            onPressed: () => _showCreatePODialog(context, store),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Bar
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  FilterChip(
                    label: const Text('All Orders'),
                    selected: _filterStatus == null,
                    onSelected: (_) => setState(() => _filterStatus = null),
                  ),
                  const SizedBox(width: 8),
                  ...PurchaseOrderStatus.values.map((status) {
                    final isSelected = _filterStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(status.displayName),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _filterStatus = status),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Divider(height: 1),

            // PO List
            Expanded(
              child: orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 56,
                            color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No purchase orders on file.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Create purchase orders to restock inventory from suppliers.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final po = orders[index];
                        final isReceived = po.status == PurchaseOrderStatus.received;

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
                                    po.orderNumber,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: (isReceived ? AppColors.stockGreen : AppColors.brandPrimary).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      po.status.displayName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isReceived ? AppColors.stockGreen : AppColors.brandPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Supplier: ${po.supplierName}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                ),
                              ),
                              Text(
                                'Ordered on ${DateFormatter.formatShort(po.orderDate)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${po.totalQuantity} items ordered: ${po.items.map((i) => "${i.quantityOrdered}x ${i.productTitle}").join(", ")}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Divider(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Cost: ${CurrencyFormatter.format(po.totalAmount, store.settings.currencySymbol)}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                                    ),
                                  ),
                                  if (!isReceived)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        store.receivePurchaseOrder(po.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Received ${po.orderNumber}. Stock automatically added to inventory!'),
                                            backgroundColor: AppColors.stockGreen,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.inventory_rounded, size: 16),
                                      label: const Text('Receive Goods (GRN)'),
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
        onPressed: () => _showCreatePODialog(context, store),
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Create PO'),
      ),
    );
  }
}

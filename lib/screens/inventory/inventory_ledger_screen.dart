import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class InventoryLedgerScreen extends StatefulWidget {
  const InventoryLedgerScreen({super.key});

  @override
  State<InventoryLedgerScreen> createState() => _InventoryLedgerScreenState();
}

class _InventoryLedgerScreenState extends State<InventoryLedgerScreen> {
  MovementType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);

    final movements = store.inventoryMovements.where((m) {
      if (_selectedFilter == null) return true;
      return m.movementType == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Inventory Movement Ledger'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips Row
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  FilterChip(
                    label: const Text('All Movements'),
                    selected: _selectedFilter == null,
                    onSelected: (_) => setState(() => _selectedFilter = null),
                  ),
                  const SizedBox(width: 8),
                  ...MovementType.values.map((type) {
                    final isSelected = _selectedFilter == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type.displayName),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedFilter = type),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Divider(height: 1),

            // Ledger Movements List
            Expanded(
              child: movements.isEmpty
                  ? Center(
                      child: Text(
                        'No movement records found.',
                        style: TextStyle(
                          color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(14),
                      itemCount: movements.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final m = movements[index];
                        final isAdd = m.quantityDelta > 0;

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
                              // Quantity Delta Badge
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: (isAdd ? AppColors.stockGreen : AppColors.errorRed).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  isAdd ? '+${m.quantityDelta}' : '${m.quantityDelta}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: isAdd ? AppColors.stockGreen : AppColors.errorRed,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.productTitle,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${m.movementType.displayName} • Ref: ${m.reference}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    if (m.notes.isNotEmpty)
                                      Text(
                                        'Note: ${m.notes}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontStyle: FontStyle.italic,
                                          color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Stock: ${m.previousStock} → ${m.newStock} • By ${m.performedBy}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Timestamp
                              Text(
                                DateFormatter.formatRelative(m.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                                ),
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
}

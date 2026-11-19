import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/store_expense.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String _selectedCategoryFilter = 'All';

  final List<String> _expenseCategories = [
    'All',
    'Utilities',
    'Rent & Facilities',
    'Store Supplies',
    'Equipment Maintenance',
    'Staff Wages',
    'Cash Drop',
    'Cleaning',
    'Miscellaneous',
  ];

  void _showAddExpenseDialog(BuildContext context, StoreProvider store) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final receiptController = TextEditingController();
    final notesController = TextEditingController();
    String selectedCat = 'Store Supplies';
    String selectedMethod = 'Cash';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Record Operating Expense'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Expense Description *',
                        hintText: 'e.g. Receipt paper rolls, Hand soap',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCat,
                      decoration: const InputDecoration(labelText: 'Expense Category'),
                      items: _expenseCategories.where((c) => c != 'All').map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedCat = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount Spent (\$) *',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedMethod,
                      decoration: const InputDecoration(labelText: 'Paid Via'),
                      items: ['Cash', 'Bank Transfer', 'Store Debit Card', 'Petty Cash'].map((m) {
                        return DropdownMenuItem(value: m, child: Text(m));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMethod = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: receiptController,
                      decoration: const InputDecoration(labelText: 'Receipt / Voucher Reference'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes (Optional)'),
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
                    final title = titleController.text.trim();
                    final amount = double.tryParse(amountController.text) ?? 0.0;
                    if (title.isNotEmpty && amount > 0) {
                      final expense = StoreExpense(
                        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
                        category: selectedCat,
                        title: title,
                        amount: amount,
                        date: DateTime.now(),
                        paymentMethod: selectedMethod,
                        receiptRef: receiptController.text.trim(),
                        notes: notesController.text.trim(),
                        recordedBy: store.currentStaff?.name ?? 'Admin',
                      );
                      store.addExpense(expense);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Expense of \$${amount.toStringAsFixed(2)} recorded.'),
                          backgroundColor: AppColors.stockGreen,
                        ),
                      );
                    }
                  },
                  child: const Text('Save Expense'),
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

    final expenses = store.expenses.where((e) {
      if (_selectedCategoryFilter == 'All') return true;
      return e.category == _selectedCategoryFilter;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Store Expenses & Outflow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Add Expense',
            onPressed: () => _showAddExpenseDialog(context, store),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Expense KPI Card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
                borderRadius: BorderRadius.circular(16),
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
                      const Text('TOTAL EXPENSES RECORDED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(store.totalOperatingExpenses, store.settings.currencySymbol),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.errorRed,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppColors.errorRed, size: 24),
                  ),
                ],
              ),
            ),

            // Category Filter Row
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _expenseCategories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _expenseCategories[index];
                  final isSelected = _selectedCategoryFilter == cat;
                  return FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategoryFilter = cat),
                  );
                },
              ),
            ),
            const Divider(height: 16),

            // Expense List
            Expanded(
              child: expenses.isEmpty
                  ? Center(
                      child: Text(
                        'No expenses found in this category.',
                        style: TextStyle(
                          color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: expenses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final exp = expenses[index];

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
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.errorRed.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.arrow_upward_rounded, color: AppColors.errorRed, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exp.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${exp.category} • Paid via ${exp.paymentMethod} • By ${exp.recordedBy}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    Text(
                                      DateFormatter.formatShort(exp.date),
                                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(exp.amount, store.settings.currencySymbol),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.errorRed,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context, store),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
        backgroundColor: AppColors.errorRed,
        foregroundColor: Colors.white,
      ),
    );
  }
}

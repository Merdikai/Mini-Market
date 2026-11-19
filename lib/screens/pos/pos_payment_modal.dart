import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cashier_keypad.dart';
import 'receipt_screen.dart';

class POSPaymentModal extends StatefulWidget {
  const POSPaymentModal({super.key});

  @override
  State<POSPaymentModal> createState() => _POSPaymentModalState();
}

class _POSPaymentModalState extends State<POSPaymentModal> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  String _tenderedInput = '';
  final TextEditingController _notesController = TextEditingController();

  double get _amountTendered {
    if (_tenderedInput.isEmpty) return 0.0;
    return double.tryParse(_tenderedInput) ?? 0.0;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == '.' && _tenderedInput.contains('.')) return;
      _tenderedInput += key;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_tenderedInput.isNotEmpty) {
        _tenderedInput = _tenderedInput.substring(0, _tenderedInput.length - 1);
      }
    });
  }

  void _onClear() {
    setState(() {
      _tenderedInput = '';
    });
  }

  void _onQuickCash(double amount) {
    setState(() {
      _tenderedInput = amount.toStringAsFixed(2);
    });
  }

  void _completePayment(StoreProvider store) {
    final totalDue = store.cartTotal;
    final tendered = _selectedMethod == PaymentMethod.cash
        ? (_amountTendered >= totalDue ? _amountTendered : totalDue)
        : totalDue;

    if (_selectedMethod == PaymentMethod.cash && tendered < totalDue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tendered amount must be greater than or equal to total due.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    try {
      final order = store.processCheckout(
        paymentMethod: _selectedMethod,
        amountTendered: tendered,
        notes: _notesController.text.trim(),
      );

      Navigator.pop(context); // Close payment modal
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(order: order),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);
    final totalDue = store.cartTotal;
    final changeDue = (_amountTendered - totalDue) > 0 ? (_amountTendered - totalDue) : 0.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tender Payment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${store.cartItemCount} items in cart',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'TOTAL DUE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(totalDue, store.settings.currencySymbol),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Payment Methods Tabs
            Text(
              'PAYMENT METHOD',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildMethodTab(PaymentMethod.cash, Icons.payments_outlined, 'Cash', isDark),
                const SizedBox(width: 8),
                _buildMethodTab(PaymentMethod.card, Icons.credit_card_rounded, 'Card / POS', isDark),
                const SizedBox(width: 8),
                _buildMethodTab(PaymentMethod.storeCredit, Icons.account_balance_wallet_outlined, 'Credit', isDark),
              ],
            ),
            const SizedBox(height: 18),

            // Cash Breakdown
            if (_selectedMethod == PaymentMethod.cash) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
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
                          'CASH TENDERED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _tenderedInput.isEmpty
                              ? '\$0.00'
                              : '\$$_tenderedInput',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'CHANGE DUE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.stockGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(changeDue, store.settings.currencySymbol),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.stockGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Touch Cashier Keypad
              CashierKeypad(
                onKeyPress: _onKeyPress,
                onBackspace: _onBackspace,
                onClear: _onClear,
                onQuickCash: _onQuickCash,
                orderTotal: totalDue,
              ),
            ] else if (_selectedMethod == PaymentMethod.card) ...[
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.contactless_rounded,
                      size: 48,
                      color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ready for Card Tap / Insert',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prompt customer on external card terminal',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Account Credit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      store.selectedCartCustomer != null
                          ? 'Debiting \$${totalDue.toStringAsFixed(2)} from ${store.selectedCartCustomer!.name}\'s balance (Current: \$${store.selectedCartCustomer!.storeCredit.toStringAsFixed(2)})'
                          : 'No customer linked to cart. Please select a registered account customer first.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Checkout Complete Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _completePayment(store),
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: Text(
                  'Complete & Print Receipt (${CurrencyFormatter.format(totalDue, store.settings.currencySymbol)})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTab(
    PaymentMethod method,
    IconData icon,
    String label,
    bool isDark,
  ) {
    final isSelected = _selectedMethod == method;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMethod = method;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.neonCyan.withValues(alpha: 0.15) : AppColors.brandPrimary.withValues(alpha: 0.12))
                : (isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceSecondary),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.neonCyan : AppColors.brandPrimary)
                  : (isDark ? AppColors.glassBorder : AppColors.lightBorder),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? (isDark ? AppColors.neonCyan : AppColors.brandPrimary)
                    : (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? AppColors.neonCyan : AppColors.brandPrimary)
                      : (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

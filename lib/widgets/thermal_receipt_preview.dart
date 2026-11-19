import 'package:flutter/material.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/sale_order.dart';
import '../models/store_settings.dart';
import '../theme/app_colors.dart';

class ThermalReceiptPreview extends StatelessWidget {
  final SaleOrder order;
  final StoreSettings settings;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;

  const ThermalReceiptPreview({
    super.key,
    required this.order,
    required this.settings,
    this.onPrint,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFD),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Receipt Paper Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              children: [
                Text(
                  settings.storeName.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  settings.tagline,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 11,
                    color: Color(0xFF475569),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '${settings.address}\nTel: ${settings.phone} | Tax ID: ${settings.taxId}',
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                _buildDashedLine(),
                const SizedBox(height: 10),

                // Order Metadata
                _buildKeyValue('INVOICE #', order.orderNumber),
                _buildKeyValue('DATE & TIME', DateFormatter.formatReceipt(order.timestamp)),
                _buildKeyValue('CASHIER', order.cashierName),
                if (order.customerName != null && order.customerName!.isNotEmpty)
                  _buildKeyValue('CUSTOMER', order.customerName!),
                _buildKeyValue('TENDER', order.paymentMethod.displayName.toUpperCase()),

                const SizedBox(height: 10),
                _buildDashedLine(),
                const SizedBox(height: 10),

                // Table Header
                const Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        'ITEM',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'QTY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'TOTAL',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Item Lines
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            item.product.title,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 11,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 11,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            CurrencyFormatter.format(item.total, settings.currencySymbol),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 11,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 10),
                _buildDashedLine(),
                const SizedBox(height: 10),

                // Totals
                _buildKeyValue('SUBTOTAL', CurrencyFormatter.format(order.subtotal, settings.currencySymbol)),
                if (order.discountAmount > 0)
                  _buildKeyValue('DISCOUNT', '-${CurrencyFormatter.format(order.discountAmount, settings.currencySymbol)}'),
                _buildKeyValue('SALES TAX (${(settings.taxRate * 100).toStringAsFixed(0)}%)',
                    CurrencyFormatter.format(order.taxAmount, settings.currencySymbol)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL DUE',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(order.total, settings.currencySymbol),
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Tender Breakdown
                _buildKeyValue('PAID AMOUNT', CurrencyFormatter.format(order.amountPaid, settings.currencySymbol)),
                _buildKeyValue('CHANGE GIVEN', CurrencyFormatter.format(order.changeGiven, settings.currencySymbol)),

                const SizedBox(height: 16),
                _buildDashedLine(),
                const SizedBox(height: 14),

                // Barcode visual representation
                Container(
                  height: 38,
                  width: 220,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(35, (index) {
                      final isThick = index % 3 == 0 || index % 7 == 0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.2),
                        width: isThick ? 2.5 : 1.2,
                        height: 32,
                        color: Colors.black87,
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.orderNumber,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 10,
                    letterSpacing: 2,
                    color: Color(0xFF475569),
                  ),
                ),

                const SizedBox(height: 14),
                Text(
                  settings.receiptHeader,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF475569),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  settings.receiptFooter,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 9,
                    color: Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Actions Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                if (onPrint != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onPrint,
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: const Text('Print Receipt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.obsidian,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                if (onPrint != null && onShare != null) const SizedBox(width: 8),
                if (onShare != null)
                  IconButton(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_outlined, color: AppColors.obsidian),
                    tooltip: 'Share Receipt',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyValue(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return Row(
      children: List.generate(40, (index) {
        return Expanded(
          child: Container(
            color: index % 2 == 0 ? const Color(0xFFCBD5E1) : Colors.transparent,
            height: 1,
          ),
        );
      }),
    );
  }
}

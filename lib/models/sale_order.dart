import '../core/constants/app_constants.dart';
import 'cart_item.dart';

class SaleOrder {
  final String id;
  final String orderNumber;
  final DateTime timestamp;
  final String cashierId;
  final String cashierName;
  final String? customerId;
  final String? customerName;
  final List<CartItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double total;
  final PaymentMethod paymentMethod;
  final double amountPaid;
  final double changeGiven;
  OrderStatus status;
  final String notes;
  bool isOfflineSynced;

  SaleOrder({
    required this.id,
    required this.orderNumber,
    required this.timestamp,
    required this.cashierId,
    required this.cashierName,
    this.customerId,
    this.customerName,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.total,
    required this.paymentMethod,
    required this.amountPaid,
    required this.changeGiven,
    this.status = OrderStatus.completed,
    this.notes = '',
    this.isOfflineSynced = true,
  });

  int get totalItemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  DateTime get date => timestamp;
}

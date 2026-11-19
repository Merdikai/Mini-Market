import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  double discountAmount; // flat discount off total line item
  String note;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.discountAmount = 0.0,
    this.note = '',
  });

  double get unitPrice => product.price;

  double get subtotal => unitPrice * quantity;

  double get total {
    final t = subtotal - discountAmount;
    return t > 0 ? t : 0.0;
  }

  double get taxAmount => total * product.taxRate;

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? discountAmount,
    String? note,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      discountAmount: discountAmount ?? this.discountAmount,
      note: note ?? this.note,
    );
  }
}

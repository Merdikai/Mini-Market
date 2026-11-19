import '../core/constants/app_constants.dart';

class PurchaseOrderItem {
  final String productId;
  final String productTitle;
  int quantityOrdered;
  int quantityReceived;
  double unitCost;

  PurchaseOrderItem({
    required this.productId,
    required this.productTitle,
    required this.quantityOrdered,
    this.quantityReceived = 0,
    required this.unitCost,
  });

  double get lineTotal => quantityOrdered * unitCost;
}

class PurchaseOrder {
  final String id;
  final String orderNumber;
  final String supplierId;
  final String supplierName;
  final DateTime orderDate;
  DateTime? expectedDelivery;
  DateTime? receivedDate;
  final List<PurchaseOrderItem> items;
  PurchaseOrderStatus status;
  final String notes;

  PurchaseOrder({
    required this.id,
    required this.orderNumber,
    required this.supplierId,
    required this.supplierName,
    required this.orderDate,
    this.expectedDelivery,
    this.receivedDate,
    required this.items,
    this.status = PurchaseOrderStatus.draft,
    this.notes = '',
  });

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantityOrdered);
  }
}

import '../core/constants/app_constants.dart';

class CashierShift {
  final String id;
  final String staffId;
  final String staffName;
  final DateTime openedAt;
  DateTime? closedAt;
  final double openingFloat;
  double totalCashSales;
  double totalCardSales;
  double totalCreditSales;
  double cashDrops;
  double? actualCashCounted;
  String notes;
  ShiftStatus status;

  CashierShift({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.openedAt,
    this.closedAt,
    required this.openingFloat,
    this.totalCashSales = 0.0,
    this.totalCardSales = 0.0,
    this.totalCreditSales = 0.0,
    this.cashDrops = 0.0,
    this.actualCashCounted,
    this.notes = '',
    this.status = ShiftStatus.open,
  });

  double get expectedCashInDrawer =>
      openingFloat + totalCashSales - cashDrops;

  double get cashDiscrepancy {
    if (actualCashCounted == null) return 0.0;
    return actualCashCounted! - expectedCashInDrawer;
  }

  bool get isOpen => status == ShiftStatus.open;
}

import '../core/constants/app_constants.dart';

class InventoryMovement {
  final String id;
  final String productId;
  final String productTitle;
  final MovementType movementType;
  final int quantityDelta;
  final int previousStock;
  final int newStock;
  final double unitCost;
  final String reference;
  final String notes;
  final String performedBy;
  final DateTime timestamp;

  const InventoryMovement({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.movementType,
    required this.quantityDelta,
    required this.previousStock,
    required this.newStock,
    this.unitCost = 0.0,
    required this.reference,
    this.notes = '',
    required this.performedBy,
    required this.timestamp,
  });
}

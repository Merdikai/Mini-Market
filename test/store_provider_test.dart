import 'package:flutter_test/flutter_test.dart';
import 'package:mini_market/core/constants/app_constants.dart';
import 'package:mini_market/providers/store_provider.dart';

void main() {
  group('StoreProvider Enterprise Business Engine Tests', () {
    late StoreProvider store;

    setUp(() {
      store = StoreProvider();
    });

    test('Initializes with default products, staff and active cashier shift', () {
      expect(store.products.isNotEmpty, isTrue);
      expect(store.staffList.isNotEmpty, isTrue);
      expect(store.activeShift, isNotNull);
      expect(store.activeShift!.isOpen, isTrue);
      expect(store.activeShift!.openingFloat, 150.0);
    });

    test('Adding products to cart computes subtotal, tax, and total accurately', () {
      final product = store.products.first; // Price: 4.50
      store.addToCart(product, 2);

      expect(store.cartItemCount, 2);
      expect(store.cartSubtotal, 9.00);

      // Tax at 8%: 9.00 * 0.08 = 0.72
      expect(store.cartTaxAmount, 0.72);
      expect(store.cartTotal, 9.72);
    });

    test('Checkout deducts inventory and logs movement to immutable ledger', () {
      final product = store.products.first;
      final initialStock = product.stock;

      store.addToCart(product, 3);
      final initialMovements = store.inventoryMovements.length;

      final order = store.processCheckout(
        paymentMethod: PaymentMethod.cash,
        amountTendered: 20.00,
        notes: 'Test cash sale',
      );

      expect(order.status, OrderStatus.completed);
      expect(product.stock, initialStock - 3);
      expect(store.inventoryMovements.length, initialMovements + 1);

      final latestMovement = store.inventoryMovements.first;
      expect(latestMovement.movementType, MovementType.sale);
      expect(latestMovement.quantityDelta, -3);
      expect(store.cart.isEmpty, isTrue);
    });

    test('Physical stocktake count audit updates stock and logs audit movement', () {
      final product = store.products[1];
      final previousStock = product.stock;

      store.adjustStock(product.id, previousStock + 5, reason: 'Physical Count Surplus');

      expect(product.stock, previousStock + 5);
      final latestMovement = store.inventoryMovements.first;
      expect(latestMovement.movementType, MovementType.stocktakeAdjustment);
      expect(latestMovement.quantityDelta, 5);
    });

    test('Cashier shift drawer reconciliation calculates overage/shortage', () {
      final shift = store.activeShift!;
      final expected = shift.expectedCashInDrawer;

      store.closeShift(expected + 10.0, notes: 'Over by ten dollars');

      expect(store.activeShift, isNull);
      expect(store.shiftHistory.first.cashDiscrepancy, 10.0);
      expect(store.shiftHistory.first.status, ShiftStatus.closed);
    });
  });
}

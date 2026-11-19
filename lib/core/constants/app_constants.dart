/// Enterprise constants for Mini Market Retail Management System
class AppConstants {
  static const String appName = 'Mini Market';
  static const String appVersion = '2.4.0';
  static const String defaultCurrencySymbol = '\$';
  static const double defaultTaxRate = 0.08; // 8% sales tax

  // Storage Keys
  static const String keyStaffSession = 'mm_staff_session';
  static const String keyActiveShift = 'mm_active_shift';
  static const String keyStoreSettings = 'mm_store_settings';
  static const String keyOfflineQueue = 'mm_offline_queue';
  static const String keyThemeMode = 'mm_theme_mode';

  // Demo / Initial Defaults
  static const String defaultStoreName = 'Mini Market Central';
  static const String defaultStoreAddress = '742 Evergreen Terrace, Retail District';
  static const String defaultStorePhone = '+1 (555) 019-2834';
  static const String defaultStoreEmail = 'contact@minimarket.store';
  static const String defaultTaxId = 'US-VAT-84920491';
  static const String defaultReceiptHeader = 'Thank you for shopping at Mini Market!';
  static const String defaultReceiptFooter = 'Goods sold in good condition. Return within 7 days with receipt.';
}

enum StaffRole {
  admin,
  manager,
  cashier,
  inventoryClerk;

  String get displayName {
    switch (this) {
      case StaffRole.admin:
        return 'Administrator';
      case StaffRole.manager:
        return 'Store Manager';
      case StaffRole.cashier:
        return 'Cashier';
      case StaffRole.inventoryClerk:
        return 'Inventory Clerk';
    }
  }

  bool get canManageStaff => this == StaffRole.admin;
  bool get canManageInventory => this == StaffRole.admin || this == StaffRole.manager || this == StaffRole.inventoryClerk;
  bool get canAccessReports => this == StaffRole.admin || this == StaffRole.manager;
  bool get canModifySettings => this == StaffRole.admin;
  bool get canApplyDiscounts => this != StaffRole.inventoryClerk;
}

enum PaymentMethod {
  cash,
  card,
  split,
  storeCredit;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card / POS';
      case PaymentMethod.split:
        return 'Split Tender';
      case PaymentMethod.storeCredit:
        return 'Store Credit';
    }
  }
}

enum OrderStatus {
  completed,
  refunded,
  voided,
  held;

  String get displayName {
    switch (this) {
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.refunded:
        return 'Refunded';
      case OrderStatus.voided:
        return 'Voided';
      case OrderStatus.held:
        return 'Held';
    }
  }
}

enum MovementType {
  purchase,
  sale,
  customerReturn,
  damaged,
  stocktakeAdjustment;

  String get displayName {
    switch (this) {
      case MovementType.purchase:
        return 'Stock In (Purchase)';
      case MovementType.sale:
        return 'Stock Out (Sale)';
      case MovementType.customerReturn:
        return 'Stock In (Return)';
      case MovementType.damaged:
        return 'Loss (Damaged/Waste)';
      case MovementType.stocktakeAdjustment:
        return 'Stocktake Audit';
    }
  }

  bool get isAddition =>
      this == MovementType.purchase || this == MovementType.customerReturn;
}

enum PurchaseOrderStatus {
  draft,
  submitted,
  received,
  cancelled;

  String get displayName {
    switch (this) {
      case PurchaseOrderStatus.draft:
        return 'Draft';
      case PurchaseOrderStatus.submitted:
        return 'Submitted';
      case PurchaseOrderStatus.received:
        return 'Goods Received';
      case PurchaseOrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum ShiftStatus {
  open,
  closed;

  String get displayName => this == ShiftStatus.open ? 'Open' : 'Closed';
}

import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/currency_formatter.dart';
import '../models/cart_item.dart';
import '../models/cashier_shift.dart';
import '../models/category.dart';
import '../models/customer.dart';
import '../models/inventory_movement.dart';
import '../models/product.dart';
import '../models/purchase_order.dart';
import '../models/sale_order.dart';
import '../models/staff_user.dart';
import '../models/store_expense.dart';
import '../models/store_settings.dart';
import '../models/supplier.dart';

class HeldCart {
  final String id;
  final String customerName;
  final DateTime heldAt;
  final List<CartItem> items;
  final double discount;

  HeldCart({
    required this.id,
    required this.customerName,
    required this.heldAt,
    required this.items,
    this.discount = 0.0,
  });
}

class StoreProvider extends ChangeNotifier {
  StoreSettings _settings = StoreSettings();
  StaffUser? _currentStaff;
  CashierShift? _activeShift;

  // Catalog Categories with Real Department Icons and Colors
  final List<ProductCategory> _categories = [
    const ProductCategory(
      id: 'cat_all',
      name: 'All Items',
      slug: 'all',
      icon: Icons.grid_view_rounded,
      color: Color(0xFF00D2E0),
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&q=80',
    ),
    const ProductCategory(
      id: 'cat_produce',
      name: 'Produce',
      slug: 'produce',
      icon: Icons.eco_rounded,
      color: Color(0xFF10B981),
      imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=400&q=80',
    ),
    const ProductCategory(
      id: 'cat_dairy',
      name: 'Dairy & Eggs',
      slug: 'dairy',
      icon: Icons.egg_alt_rounded,
      color: Color(0xFFF59E0B),
      imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
    ),
    const ProductCategory(
      id: 'cat_bakery',
      name: 'Bakery',
      slug: 'bakery',
      icon: Icons.bakery_dining_rounded,
      color: Color(0xFFD97706),
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=400&q=80',
    ),
    const ProductCategory(
      id: 'cat_beverages',
      name: 'Beverages',
      slug: 'beverages',
      icon: Icons.local_cafe_rounded,
      color: Color(0xFF3B82F6),
      imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=400&q=80',
    ),
    const ProductCategory(
      id: 'cat_snacks',
      name: 'Snacks & Pantry',
      slug: 'snacks',
      icon: Icons.cookie_rounded,
      color: Color(0xFFEC4899),
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80',
    ),
    const ProductCategory(
      id: 'cat_household',
      name: 'Household',
      slug: 'household',
      icon: Icons.cleaning_services_rounded,
      color: Color(0xFF8B5CF6),
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=400&q=80',
    ),
  ];

  // Comprehensive Real Product Catalog with Unsplash CDN Images
  final List<Product> _products = [
    Product(
      id: 'prod_1',
      sku: 'MM-BEV-001',
      barcode: '012000000133',
      title: 'Artisan Cold Brew Coffee',
      price: 4.50,
      costPrice: 1.80,
      category: 'Beverages',
      description: 'Single-origin Ethiopian cold-steeped Arabica coffee with crisp cocoa notes in recyclable glass bottle (350ml).',
      imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=600&q=80',
      icon: Icons.local_cafe,
      stock: 38,
      minStock: 10,
      unit: 'bottle',
      isFeatured: true,
      badge: 'TOP SELLER',
    ),
    Product(
      id: 'prod_2',
      sku: 'MM-PROD-002',
      barcode: '012000000240',
      title: 'Organic Hass Avocados',
      price: 1.95,
      costPrice: 0.85,
      category: 'Produce',
      description: 'Hand-picked ripe creamy Hass avocados imported from sustainable California groves. Perfect for salads and toast.',
      imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&w=600&q=80',
      icon: Icons.eco,
      stock: 45,
      minStock: 12,
      unit: 'pcs',
      isFeatured: true,
      badge: 'ORGANIC',
    ),
    Product(
      id: 'prod_3',
      sku: 'MM-BAKE-003',
      barcode: '012000000357',
      title: 'Rustic Country Sourdough',
      price: 5.25,
      costPrice: 2.10,
      category: 'Bakery',
      description: 'Fermented 36-hour wild yeast sourdough bread with blistering crackly crust and airy, chewy crumb structure.',
      imageUrl: 'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?auto=format&fit=crop&w=600&q=80',
      icon: Icons.bakery_dining,
      stock: 14,
      minStock: 6,
      unit: 'loaf',
      isFeatured: true,
      badge: 'FRESH BAKE',
    ),
    Product(
      id: 'prod_4',
      sku: 'MM-DAIRY-004',
      barcode: '012000000464',
      title: 'Pasture-Raised Whole Milk',
      price: 3.85,
      costPrice: 2.15,
      category: 'Dairy & Eggs',
      description: 'Certified non-homogenized grass-fed 100% whole milk from local family dairies. Grade A pasteurized (1 Quart).',
      imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?auto=format&fit=crop&w=600&q=80',
      icon: Icons.egg_alt,
      stock: 22,
      minStock: 8,
      unit: 'bottle',
      isDailyDrop: true,
      badge: 'FARM FRESH',
    ),
    Product(
      id: 'prod_5',
      sku: 'MM-SNACK-005',
      barcode: '012000000571',
      title: 'Dark Chocolate Sea Salt Bar',
      price: 3.20,
      costPrice: 1.40,
      category: 'Snacks & Pantry',
      description: '72% Single-estate dark Ecuadorian chocolate finished with hand-harvested flaky French Guerande sea salt crystals.',
      imageUrl: 'https://images.unsplash.com/photo-1548907040-4baa42d10919?auto=format&fit=crop&w=600&q=80',
      icon: Icons.cookie,
      stock: 60,
      minStock: 15,
      unit: 'bar',
      isDailyDrop: true,
      badge: 'FAIR TRADE',
    ),
    Product(
      id: 'prod_6',
      sku: 'MM-PROD-006',
      barcode: '012000000688',
      title: 'Heirloom Vine Tomatoes',
      price: 3.40,
      costPrice: 1.60,
      category: 'Produce',
      description: 'Sweet, vibrant red vine-ripened heirloom greenhouse tomatoes rich in lycopene and aromatic summer sweetness.',
      imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=600&q=80',
      icon: Icons.eco,
      stock: 4, // Intentionally low for testing alert badges
      minStock: 10,
      unit: 'kg',
      badge: 'LOW STOCK',
    ),
    Product(
      id: 'prod_7',
      sku: 'MM-BEV-007',
      barcode: '012000000795',
      title: 'Sparkling Mineral Water',
      price: 2.10,
      costPrice: 0.75,
      category: 'Beverages',
      description: 'Naturally effervescent alpine spring water bottled at the volcanic source in glass carafes (750ml).',
      imageUrl: 'https://images.unsplash.com/photo-1559839914-ba2ce1817551?auto=format&fit=crop&w=600&q=80',
      icon: Icons.local_cafe,
      stock: 80,
      minStock: 20,
      unit: 'bottle',
    ),
    Product(
      id: 'prod_8',
      sku: 'MM-DAIRY-008',
      barcode: '012000000801',
      title: 'Aged White Cheddar Cheese',
      price: 6.75,
      costPrice: 3.80,
      category: 'Dairy & Eggs',
      description: 'Handcrafted Vermont raw-milk sharp cheddar naturally cave-aged for 18 months for distinctive crystalline bite.',
      imageUrl: 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?auto=format&fit=crop&w=600&q=80',
      icon: Icons.egg_alt,
      stock: 18,
      minStock: 5,
      unit: 'block',
      isFeatured: true,
      badge: 'RESERVE',
    ),
    Product(
      id: 'prod_9',
      sku: 'MM-HOUSE-009',
      barcode: '012000000918',
      title: 'Eco Citrus Dish Wash Liquid',
      price: 4.80,
      costPrice: 2.20,
      category: 'Household',
      description: 'Plant-based biodegradable concentrated washing formula infused with organic cold-pressed sweet orange peel oils.',
      imageUrl: 'https://images.unsplash.com/photo-1585421514738-01798e348b17?auto=format&fit=crop&w=600&q=80',
      icon: Icons.cleaning_services,
      stock: 25,
      minStock: 8,
      unit: 'bottle',
    ),
    Product(
      id: 'prod_10',
      sku: 'MM-SNACK-010',
      barcode: '012000001021',
      title: 'Sea Salt Roasted Almonds',
      price: 5.90,
      costPrice: 3.10,
      category: 'Snacks & Pantry',
      description: 'California nonpareil jumbo almonds slow dry-roasted and dusted with fine Mediterranean salt (250g pouch).',
      imageUrl: 'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?auto=format&fit=crop&w=600&q=80',
      icon: Icons.cookie,
      stock: 34,
      minStock: 10,
      unit: 'pack',
      isDailyDrop: true,
    ),
  ];

  // POS Live Cart & Held Transactions
  final List<CartItem> _cart = [];
  final List<HeldCart> _heldCarts = [];
  final Set<String> _favorites = {'prod_1', 'prod_2', 'prod_3'};
  double _cartDiscountAmount = 0.0;
  String? _activeCouponCode;
  Customer? _selectedCartCustomer;

  // Audit Logs & System Ledgers
  final List<SaleOrder> _salesHistory = [];
  final List<InventoryMovement> _inventoryMovements = [];
  final List<StoreExpense> _expenses = [];
  final List<CashierShift> _shiftHistory = [];

  // Directory of Staff Users
  final List<StaffUser> _staffList = [
    const StaffUser(
      id: 'staff_1',
      name: 'Alex Rivera',
      email: 'alex.rivera@minimarket.store',
      role: StaffRole.admin,
      pin: '1234',
      phone: '+1 (555) 012-3456',
    ),
    const StaffUser(
      id: 'staff_2',
      name: 'Elena Rostova',
      email: 'elena.r@minimarket.store',
      role: StaffRole.manager,
      pin: '2345',
      phone: '+1 (555) 019-8765',
    ),
    const StaffUser(
      id: 'staff_3',
      name: 'Marcus Chen',
      email: 'marcus.c@minimarket.store',
      role: StaffRole.cashier,
      pin: '0000',
      phone: '+1 (555) 017-4321',
    ),
    const StaffUser(
      id: 'staff_4',
      name: 'Samira Khan',
      email: 'samira.k@minimarket.store',
      role: StaffRole.inventoryClerk,
      pin: '4321',
      phone: '+1 (555) 014-9988',
    ),
  ];

  // Directory of Suppliers
  final List<Supplier> _suppliers = [
    Supplier(
      id: 'sup_1',
      name: 'Pacific Fresh Organics',
      companyName: 'Pacific Organics LLC',
      email: 'orders@pacificorganics.com',
      phone: '+1 (555) 832-1100',
      address: '120 Harvest Way, Salinas, CA',
      taxId: 'US-EIN-984124',
      balance: 1450.0,
    ),
    Supplier(
      id: 'sup_2',
      name: 'Valley Dairy Cooperative',
      companyName: 'Valley Dairy Farm Co-op',
      email: 'dispatch@valleydairy.org',
      phone: '+1 (555) 441-9922',
      address: '840 Meadow Lane, Petaluma, CA',
      taxId: 'US-EIN-549102',
      balance: 820.50,
    ),
    Supplier(
      id: 'sup_3',
      name: 'Heritage Flour & Mill',
      companyName: 'Heritage Bakery Supply',
      email: 'supply@heritagermill.com',
      phone: '+1 (555) 723-5588',
      address: '300 Grain Silo Rd, Portland, OR',
      taxId: 'US-EIN-332918',
      balance: 0.0,
    ),
  ];

  // Directory of Purchase Orders
  final List<PurchaseOrder> _purchaseOrders = [];

  // Customer CRM Profiles
  final List<Customer> _customers = [
    Customer(
      id: 'cust_1',
      name: 'Sophia Montgomery',
      phone: '+1 (555) 321-7788',
      email: 'sophia.m@gmail.com',
      address: '14 Elm Court, Apt 3B',
      loyaltyPoints: 340,
      storeCredit: 25.00,
      totalSpent: 480.50,
      visitCount: 18,
      notes: 'Prefers non-dairy alternatives and fresh sourdough.',
    ),
    Customer(
      id: 'cust_2',
      name: 'David K. Vance',
      phone: '+1 (555) 908-1122',
      email: 'david.vance@techfirm.io',
      address: '890 Corporate Blvd, Suite 400',
      loyaltyPoints: 120,
      storeCredit: 0.0,
      totalSpent: 215.00,
      visitCount: 7,
      notes: 'Buys cold brew daily during morning commute.',
    ),
    Customer(
      id: 'cust_3',
      name: 'Maria Santos',
      phone: '+1 (555) 674-3321',
      email: 'msantos@healthclinic.org',
      address: '52 Evergreen Terrace',
      loyaltyPoints: 580,
      storeCredit: 50.00,
      totalSpent: 920.00,
      visitCount: 32,
      notes: 'VIP customer. Eligible for 10% loyalty voucher.',
    ),
  ];

  // Filtering & Search
  String _selectedCategory = 'All';
  String _searchQuery = '';

  StoreProvider() {
    _initializeDefaultState();
  }

  void _initializeDefaultState() {
    _currentStaff = _staffList.first; // Alex Rivera (Admin)

    // Automatically open today's cashier shift with $150 opening float
    _activeShift = CashierShift(
      id: 'shift_${DateTime.now().millisecondsSinceEpoch}',
      staffId: _currentStaff!.id,
      staffName: _currentStaff!.name,
      openedAt: DateTime.now().subtract(const Duration(hours: 4)),
      openingFloat: 150.0,
      notes: 'Morning shift drawer float verified.',
    );

    // Seed realistic sample past sale orders
    final sampleOrder1 = SaleOrder(
      id: 'ord_sample_1',
      orderNumber: 'ORD-20261119-0001',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      cashierId: _currentStaff!.id,
      cashierName: _currentStaff!.name,
      customerName: 'Sophia Montgomery',
      items: [
        CartItem(product: _products[0], quantity: 2),
        CartItem(product: _products[2], quantity: 1),
      ],
      subtotal: 14.25,
      taxAmount: 1.14,
      discountAmount: 0.0,
      total: 15.39,
      paymentMethod: PaymentMethod.card,
      amountPaid: 15.39,
      changeGiven: 0.0,
      status: OrderStatus.completed,
    );
    _salesHistory.add(sampleOrder1);

    final sampleOrder2 = SaleOrder(
      id: 'ord_sample_2',
      orderNumber: 'ORD-20261119-0002',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      cashierId: _currentStaff!.id,
      cashierName: _currentStaff!.name,
      customerName: 'David K. Vance',
      items: [
        CartItem(product: _products[1], quantity: 3),
        CartItem(product: _products[4], quantity: 2),
      ],
      subtotal: 12.25,
      taxAmount: 0.98,
      discountAmount: 0.0,
      total: 13.23,
      paymentMethod: PaymentMethod.cash,
      amountPaid: 20.00,
      changeGiven: 6.77,
      status: OrderStatus.completed,
    );
    _salesHistory.add(sampleOrder2);

    _activeShift!.totalCardSales += 15.39;
    _activeShift!.totalCashSales += 13.23;

    // Seed sample initial stock movements
    _inventoryMovements.add(
      InventoryMovement(
        id: 'mov_1',
        productId: _products[0].id,
        productTitle: _products[0].title,
        movementType: MovementType.purchase,
        quantityDelta: 40,
        previousStock: 0,
        newStock: 40,
        unitCost: _products[0].costPrice,
        reference: 'GRN-202611-001',
        performedBy: 'Elena Rostova',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );

    // Seed sample operating expense
    _expenses.add(
      StoreExpense(
        id: 'exp_1',
        category: 'Utilities',
        title: 'Weekly Walk-In Cooler Refrigeration Maintenance',
        amount: 85.00,
        date: DateTime.now().subtract(const Duration(days: 2)),
        paymentMethod: 'Cash',
        receiptRef: 'RCP-TECH-4891',
        recordedBy: 'Alex Rivera',
      ),
    );
  }

  // Getters
  StoreSettings get settings => _settings;
  StaffUser? get currentStaff => _currentStaff;
  CashierShift? get activeShift => _activeShift;
  List<ProductCategory> get categoriesList => _categories;
  List<Product> get products => _products;
  List<CartItem> get cart => _cart;
  List<HeldCart> get heldCarts => _heldCarts;
  Set<String> get favorites => _favorites;
  Customer? get selectedCartCustomer => _selectedCartCustomer;
  List<SaleOrder> get salesHistory => _salesHistory;
  List<SaleOrder> get orders => _salesHistory; // Backward compatibility
  List<InventoryMovement> get inventoryMovements => _inventoryMovements;
  List<StaffUser> get staffList => _staffList;
  List<Supplier> get suppliers => _suppliers;
  List<PurchaseOrder> get purchaseOrders => _purchaseOrders;
  List<Customer> get customers => _customers;
  List<StoreExpense> get expenses => _expenses;
  List<CashierShift> get shiftHistory => _shiftHistory;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  double get cartDiscountAmount => _cartDiscountAmount;
  double get appliedDiscount => cartSubtotal > 0 ? (_cartDiscountAmount / cartSubtotal) : 0.0; // Backward compatibility
  String? get activeCouponCode => _activeCouponCode;

  List<String> get categories => [
        'All',
        'Produce',
        'Dairy & Eggs',
        'Bakery',
        'Beverages',
        'Snacks & Pantry',
        'Household',
      ];

  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchesCategory = _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.barcode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<Product> get lowStockProducts =>
      _products.where((p) => p.isLowStock || p.isOutOfStock).toList();

  List<Product> get featuredProducts =>
      _products.where((p) => p.isFeatured).toList();

  List<Product> get dailyDrops =>
      _products.where((p) => p.isDailyDrop).toList();

  // Cart Computations
  double get cartSubtotal =>
      _cart.fold(0.0, (sum, item) => sum + item.total);

  double get cartTaxAmount =>
      CurrencyFormatter.calculateTax(cartSubtotal - _cartDiscountAmount, _settings.taxRate);

  double get cartTotal {
    final subtotal = cartSubtotal;
    final afterDiscount = subtotal - _cartDiscountAmount;
    final taxable = afterDiscount > 0 ? afterDiscount : 0.0;
    final tax = CurrencyFormatter.calculateTax(taxable, _settings.taxRate);
    return CurrencyFormatter.round(taxable + tax);
  }

  int get cartItemCount =>
      _cart.fold(0, (sum, item) => sum + item.quantity);

  // Analytics & KPIs
  double get todaySalesTotal => _salesHistory
      .where((s) => s.status == OrderStatus.completed)
      .fold(0.0, (sum, s) => sum + s.total);

  int get todayOrdersCount => _salesHistory
      .where((s) => s.status == OrderStatus.completed)
      .length;

  double get totalInventoryCostValue =>
      _products.fold(0.0, (sum, p) => sum + (p.costPrice * p.stock));

  double get totalInventoryRetailValue =>
      _products.fold(0.0, (sum, p) => sum + (p.price * p.stock));

  double get potentialInventoryProfit =>
      totalInventoryRetailValue - totalInventoryCostValue;

  double get totalOperatingExpenses =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  // Authentication & Shift Management
  bool authenticatePin(String pin) {
    final matched = _staffList.where((s) => s.pin == pin && s.isActive);
    if (matched.isNotEmpty) {
      _currentStaff = matched.first;
      notifyListeners();
      return true;
    }
    return false;
  }

  void switchStaff(StaffUser staff) {
    _currentStaff = staff;
    notifyListeners();
  }

  void openShift(double openingFloat, {String notes = ''}) {
    if (_activeShift != null && _activeShift!.isOpen) return;

    _activeShift = CashierShift(
      id: 'shift_${DateTime.now().millisecondsSinceEpoch}',
      staffId: _currentStaff?.id ?? 'staff_1',
      staffName: _currentStaff?.name ?? 'Alex Rivera',
      openedAt: DateTime.now(),
      openingFloat: openingFloat,
      notes: notes,
    );
    notifyListeners();
  }

  void closeShift(double actualCashCounted, {String notes = ''}) {
    if (_activeShift == null) return;
    _activeShift!.closedAt = DateTime.now();
    _activeShift!.actualCashCounted = actualCashCounted;
    _activeShift!.notes = notes;
    _activeShift!.status = ShiftStatus.closed;
    _shiftHistory.insert(0, _activeShift!);
    _activeShift = null;
    notifyListeners();
  }

  void recordCashDrop(double amount, String reason) {
    if (_activeShift == null || amount <= 0) return;
    _activeShift!.cashDrops += amount;
    _expenses.add(
      StoreExpense(
        id: 'drop_${DateTime.now().millisecondsSinceEpoch}',
        category: 'Cash Drop',
        title: 'Safe Drop: $reason',
        amount: amount,
        date: DateTime.now(),
        paymentMethod: 'Cash',
        recordedBy: _currentStaff?.name ?? 'System',
      ),
    );
    notifyListeners();
  }

  // POS Cart Actions
  void addToCart(Product product, [int quantity = 1]) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _cart[index].quantity += quantity;
    } else {
      _cart.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateCartQuantity(String productId, int quantity) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void setCartItemDiscount(String productId, double discount) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      _cart[index].discountAmount = discount;
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _cartDiscountAmount = 0.0;
    _activeCouponCode = null;
    _selectedCartCustomer = null;
    notifyListeners();
  }

  void setCartCustomer(Customer? customer) {
    _selectedCartCustomer = customer;
    notifyListeners();
  }

  void holdCart(String customerName) {
    if (_cart.isEmpty) return;
    _heldCarts.add(
      HeldCart(
        id: 'hold_${DateTime.now().millisecondsSinceEpoch}',
        customerName: customerName.isNotEmpty ? customerName : 'Walk-in Customer',
        heldAt: DateTime.now(),
        items: List.from(_cart),
        discount: _cartDiscountAmount,
      ),
    );
    clearCart();
  }

  void recallHeldCart(HeldCart held) {
    _cart.clear();
    _cart.addAll(held.items);
    _cartDiscountAmount = held.discount;
    _heldCarts.removeWhere((h) => h.id == held.id);
    notifyListeners();
  }

  void discardHeldCart(String heldId) {
    _heldCarts.removeWhere((h) => h.id == heldId);
    notifyListeners();
  }

  bool applyCoupon(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'WELCOME10') {
      _cartDiscountAmount = CurrencyFormatter.round(cartSubtotal * 0.10);
      _activeCouponCode = clean;
      notifyListeners();
      return true;
    } else if (clean == 'SAVE20') {
      _cartDiscountAmount = CurrencyFormatter.round(cartSubtotal * 0.20);
      _activeCouponCode = clean;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Compatibility placeOrder
  void placeOrder() {
    if (_cart.isEmpty) return;
    processCheckout(
      paymentMethod: PaymentMethod.card,
      amountTendered: cartTotal,
      notes: 'Placed via Quick Checkout',
    );
  }

  // POS Checkout Execution
  SaleOrder processCheckout({
    required PaymentMethod paymentMethod,
    required double amountTendered,
    String notes = '',
  }) {
    if (_cart.isEmpty) {
      throw Exception('Cart cannot be empty for checkout.');
    }

    final totalDue = cartTotal;
    final change = (amountTendered - totalDue) > 0 ? (amountTendered - totalDue) : 0.0;
    final orderNum = 'ORD-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${(_salesHistory.length + 1).toString().padLeft(4, '0')}';

    final completedOrder = SaleOrder(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: orderNum,
      timestamp: DateTime.now(),
      cashierId: _currentStaff?.id ?? 'staff_1',
      cashierName: _currentStaff?.name ?? 'Alex Rivera',
      customerId: _selectedCartCustomer?.id,
      customerName: _selectedCartCustomer?.name ?? 'Walk-in Customer',
      items: List.from(_cart),
      subtotal: cartSubtotal,
      taxAmount: cartTaxAmount,
      discountAmount: _cartDiscountAmount,
      total: totalDue,
      paymentMethod: paymentMethod,
      amountPaid: amountTendered,
      changeGiven: CurrencyFormatter.round(change),
      status: OrderStatus.completed,
      notes: notes,
    );

    // 1. Decrement Inventory & Log Movements
    for (final item in _cart) {
      final pIndex = _products.indexWhere((p) => p.id == item.product.id);
      if (pIndex != -1) {
        final prev = _products[pIndex].stock;
        final next = (prev - item.quantity) > 0 ? (prev - item.quantity) : 0;
        _products[pIndex].stock = next;

        _inventoryMovements.insert(
          0,
          InventoryMovement(
            id: 'mov_${DateTime.now().millisecondsSinceEpoch}_${item.product.id}',
            productId: item.product.id,
            productTitle: item.product.title,
            movementType: MovementType.sale,
            quantityDelta: -item.quantity,
            previousStock: prev,
            newStock: next,
            unitCost: item.product.costPrice,
            reference: completedOrder.orderNumber,
            performedBy: _currentStaff?.name ?? 'Cashier',
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    // 2. Update Active Shift Cash/Card Tracking
    if (_activeShift != null) {
      if (paymentMethod == PaymentMethod.cash) {
        _activeShift!.totalCashSales += totalDue;
      } else if (paymentMethod == PaymentMethod.card) {
        _activeShift!.totalCardSales += totalDue;
      } else if (paymentMethod == PaymentMethod.storeCredit) {
        _activeShift!.totalCreditSales += totalDue;
      }
    }

    // 3. Update Customer CRM Stats & Loyalty Points
    if (_selectedCartCustomer != null) {
      final cIndex = _customers.indexWhere((c) => c.id == _selectedCartCustomer!.id);
      if (cIndex != -1) {
        _customers[cIndex].visitCount += 1;
        _customers[cIndex].totalSpent += totalDue;
        // Award 1 point per dollar spent
        _customers[cIndex].loyaltyPoints += totalDue.floor();

        if (paymentMethod == PaymentMethod.storeCredit) {
          _customers[cIndex].storeCredit -= totalDue;
        }
      }
    }

    _salesHistory.insert(0, completedOrder);
    clearCart();
    return completedOrder;
  }

  // Returns and Refunds
  void processRefund(String orderId, {String reason = 'Customer Return'}) {
    final oIndex = _salesHistory.indexWhere((o) => o.id == orderId);
    if (oIndex != -1 && _salesHistory[oIndex].status != OrderStatus.refunded) {
      final order = _salesHistory[oIndex];
      order.status = OrderStatus.refunded;

      // Restock items in inventory
      for (final item in order.items) {
        final pIndex = _products.indexWhere((p) => p.id == item.product.id);
        if (pIndex != -1) {
          final prev = _products[pIndex].stock;
          final next = prev + item.quantity;
          _products[pIndex].stock = next;

          _inventoryMovements.insert(
            0,
            InventoryMovement(
              id: 'mov_ret_${DateTime.now().millisecondsSinceEpoch}_${item.product.id}',
              productId: item.product.id,
              productTitle: item.product.title,
              movementType: MovementType.customerReturn,
              quantityDelta: item.quantity,
              previousStock: prev,
              newStock: next,
              unitCost: item.product.costPrice,
              reference: 'REFUND-${order.orderNumber}',
              notes: reason,
              performedBy: _currentStaff?.name ?? 'Staff',
              timestamp: DateTime.now(),
            ),
          );
        }
      }
      notifyListeners();
    }
  }

  // Inventory Adjustments & Stocktake Audit
  void adjustStock(String productId, int newCount, {String reason = 'Physical Count Audit'}) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final prev = _products[index].stock;
      final delta = newCount - prev;
      _products[index].stock = newCount;

      _inventoryMovements.insert(
        0,
        InventoryMovement(
          id: 'mov_adj_${DateTime.now().millisecondsSinceEpoch}',
          productId: productId,
          productTitle: _products[index].title,
          movementType: MovementType.stocktakeAdjustment,
          quantityDelta: delta,
          previousStock: prev,
          newStock: newCount,
          unitCost: _products[index].costPrice,
          reference: 'AUDIT-${DateTime.now().month}-${DateTime.now().day}',
          notes: reason,
          performedBy: _currentStaff?.name ?? 'Inventory Auditor',
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();
    }
  }

  void logDamagedGoods(String productId, int quantity, String reason) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1 && quantity > 0) {
      final prev = _products[index].stock;
      final next = (prev - quantity) > 0 ? (prev - quantity) : 0;
      _products[index].stock = next;

      _inventoryMovements.insert(
        0,
        InventoryMovement(
          id: 'mov_dam_${DateTime.now().millisecondsSinceEpoch}',
          productId: productId,
          productTitle: _products[index].title,
          movementType: MovementType.damaged,
          quantityDelta: -quantity,
          previousStock: prev,
          newStock: next,
          unitCost: _products[index].costPrice,
          reference: 'DAMAGE-LOG',
          notes: reason,
          performedBy: _currentStaff?.name ?? 'Staff',
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();
    }
  }

  // Product CRUD
  void addProduct(Product product) {
    _products.insert(0, product);
    _inventoryMovements.insert(
      0,
      InventoryMovement(
        id: 'mov_init_${DateTime.now().millisecondsSinceEpoch}',
        productId: product.id,
        productTitle: product.title,
        movementType: MovementType.purchase,
        quantityDelta: product.stock,
        previousStock: 0,
        newStock: product.stock,
        unitCost: product.costPrice,
        reference: 'INITIAL-STOCK',
        performedBy: _currentStaff?.name ?? 'Admin',
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void updateProduct(Product updated) {
    final index = _products.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _products[index] = updated;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    _cart.removeWhere((item) => item.product.id == id);
    _favorites.remove(id);
    notifyListeners();
  }

  // Supplier & Purchasing Management
  void addSupplier(Supplier supplier) {
    _suppliers.add(supplier);
    notifyListeners();
  }

  void updateSupplier(Supplier updated) {
    final index = _suppliers.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _suppliers[index] = updated;
      notifyListeners();
    }
  }

  void createPurchaseOrder(PurchaseOrder po) {
    _purchaseOrders.insert(0, po);
    notifyListeners();
  }

  void receivePurchaseOrder(String poId) {
    final index = _purchaseOrders.indexWhere((po) => po.id == poId);
    if (index != -1 && _purchaseOrders[index].status != PurchaseOrderStatus.received) {
      final po = _purchaseOrders[index];
      po.status = PurchaseOrderStatus.received;
      po.receivedDate = DateTime.now();

      // Automatically restock inventory for each ordered item
      for (final item in po.items) {
        final pIndex = _products.indexWhere((p) => p.id == item.productId);
        if (pIndex != -1) {
          final prev = _products[pIndex].stock;
          final next = prev + item.quantityOrdered;
          _products[pIndex].stock = next;
          item.quantityReceived = item.quantityOrdered;

          _inventoryMovements.insert(
            0,
            InventoryMovement(
              id: 'mov_po_${DateTime.now().millisecondsSinceEpoch}_${item.productId}',
              productId: item.productId,
              productTitle: item.productTitle,
              movementType: MovementType.purchase,
              quantityDelta: item.quantityOrdered,
              previousStock: prev,
              newStock: next,
              unitCost: item.unitCost,
              reference: po.orderNumber,
              performedBy: _currentStaff?.name ?? 'Purchaser',
              timestamp: DateTime.now(),
            ),
          );
        }
      }
      notifyListeners();
    }
  }

  // Customer Management
  void addCustomer(Customer customer) {
    _customers.insert(0, customer);
    notifyListeners();
  }

  void updateCustomer(Customer updated) {
    final index = _customers.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _customers[index] = updated;
      notifyListeners();
    }
  }

  void addStoreCredit(String customerId, double amount) {
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1 && amount > 0) {
      _customers[index].storeCredit += amount;
      notifyListeners();
    }
  }

  // Expense Management
  void addExpense(StoreExpense expense) {
    _expenses.insert(0, expense);
    notifyListeners();
  }

  // Store Settings & Theming
  void updateSettings(StoreSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  void toggleTheme() {
    _settings.isDarkMode = !_settings.isDarkMode;
    notifyListeners();
  }

  void toggleDemoFrame() {
    _settings.isDemoFrameVisible = !_settings.isDemoFrameVisible;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    if (_favorites.contains(productId)) {
      _favorites.remove(productId);
    } else {
      _favorites.add(productId);
    }
    notifyListeners();
  }

  bool isFavorite(String productId) => _favorites.contains(productId);

  Product getProductById(String id) =>
      _products.firstWhere((p) => p.id == id, orElse: () => _products.first);
}

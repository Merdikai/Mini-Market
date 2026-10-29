import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../theme/app_colors.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime date;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    required this.status,
  });
}

class StoreProvider extends ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: '1',
      title: 'Ora Chrono Geneva 01',
      price: 1850.0,
      category: 'Horology',
      description:
          'Precision Geneva-crafted automatic chronograph featuring a 240-step scrubbed sapphire canvas, obsidian black ceramic bezel, and open mechanical escapement.',
      icon: Icons.watch,
      color: AppColors.champagneGold,
      rating: 4.98,
      reviewCount: 342,
      isFeatured: true,
      isDailyDrop: true,
      stock: 4,
      badge: 'GENEVA DROP',
      specs: {
        'Movement': 'Swiss Calibre 9012 Automatic',
        'Crystal': 'Scratched-Proof Double Sapphire',
        'Case Diameter': '41mm Grade-5 Titanium',
        'Water Resistance': '100m / 10 ATM',
        'Power Reserve': '72 Hours',
      },
    ),
    Product(
      id: '2',
      title: 'Artefakt Lattice Parka',
      price: 740.0,
      category: 'Cyber Apparel',
      description:
          'Near-black iridescent outerwear engineered with reactive carbon lattice membrane. Illuminates under environmental lumina and repels torrential storm conditions.',
      icon: Icons.checkroom,
      color: AppColors.neonCyan,
      rating: 4.95,
      reviewCount: 189,
      isFeatured: true,
      isDailyDrop: false,
      stock: 9,
      badge: 'LIMITED RUN',
      specs: {
        'Fabric': 'Triple-Lacquered Carbon Weave',
        'Membrane': 'Hydro-Shield 30K Reactive',
        'Insulation': 'Graphene Aerogel 120g',
        'Hardware': 'Matte Anodized Magnetic Clasps',
      },
    ),
    Product(
      id: '3',
      title: 'Cyber Pulse Audio Buds',
      price: 299.0,
      category: 'Audio',
      description:
          'Spatial planar-magnetic monitors with titanium acoustics, active zero-latency spatial positioning, and frosted matte smoke charging capsule.',
      icon: Icons.headphones,
      color: AppColors.cyberEmerald,
      rating: 4.88,
      reviewCount: 512,
      isFeatured: true,
      isDailyDrop: false,
      stock: 22,
      badge: 'BESTSELLER',
      specs: {
        'Driver': '12mm Planar Magnetic',
        'Latency': '18ms Ultra-Low Sync',
        'Battery': '38h with Charging Pod',
        'Noise Cancelling': '-48dB Adaptive Hybrid ANC',
      },
    ),
    Product(
      id: '4',
      title: 'Quantum Apex Drone EDC',
      price: 1290.0,
      category: 'Futuristic EDC',
      description:
          'Compact carbon fiber autonomous companion with 8K HDR gimbal sensor, omnidirectional LiDAR collision matrix, and haptic wrist transmitter.',
      icon: Icons.flight_takeoff,
      color: AppColors.electricViolet,
      rating: 4.92,
      reviewCount: 94,
      isFeatured: false,
      isDailyDrop: true,
      stock: 6,
      badge: 'AI EDITION',
      specs: {
        'Sensor': '1-Inch CMOS 8K 60fps',
        'Weight': '249g Ultra-Light Class',
        'Transmission': '15km Tri-Band O3 Pro',
        'Flight Time': '42 Minutes',
      },
    ),
    Product(
      id: '5',
      title: 'Titan Obsidian Blade Phone',
      price: 1450.0,
      category: 'Hardware',
      description:
          'Ultra-thin architectural smartphone constructed from single-crystal forged titanium, bezel-less micro-OLED panel, and privacy quantum encryption core.',
      icon: Icons.smartphone,
      color: AppColors.liquidRose,
      rating: 4.97,
      reviewCount: 420,
      isFeatured: true,
      isDailyDrop: false,
      stock: 12,
      badge: 'FLAGSHIP',
      specs: {
        'Display': '6.8-Inch Micro-OLED 144Hz 3000nits',
        'Processor': 'Octa-Core 3nm Neural Engine',
        'Chassis': 'Aero-Grade Titanium Unibody',
        'Security': 'Sub-Screen Ultrasonic Crypt Key',
      },
    ),
    Product(
      id: '6',
      title: 'Neural VR Vision Visor',
      price: 980.0,
      category: 'Hardware',
      description:
          'Next-generation ultra-light spatial computing visor with eye-tracking foveated rendering, spatial holographic audio, and magnetic light seal.',
      icon: Icons.visibility,
      color: AppColors.neonCyan,
      rating: 4.86,
      reviewCount: 164,
      isFeatured: false,
      isDailyDrop: false,
      stock: 18,
      badge: 'SPATIAL OS',
      specs: {
        'Resolution': '4K Dual Micro-OLED Per Eye',
        'Tracking': '6DoF Inside-Out LiDAR Matrix',
        'Refresh Rate': '120Hz Low Persistence',
        'Weight': '210g Balanced Ergonomics',
      },
    ),
  ];

  final List<CartItem> _cart = [];
  final Set<String> _favorites = {'1', '2'};
  final List<Order> _orders = [
    Order(
      id: 'MM-89241',
      items: [
        CartItem(
          product: Product(
            id: '1',
            title: 'Ora Chrono Geneva 01',
            price: 1850.0,
            category: 'Horology',
            description: 'Geneva-crafted automatic chronograph.',
            icon: Icons.watch,
            color: AppColors.champagneGold,
          ),
          quantity: 1,
        ),
      ],
      total: 1850.0,
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Delivered',
    ),
  ];

  String _selectedCategory = 'All';
  String _searchQuery = '';
  double _appliedDiscount = 0.0;
  String? _activeCouponCode;

  List<Product> get products => _products;
  List<CartItem> get cart => _cart;
  Set<String> get favorites => _favorites;
  List<Order> get orders => _orders;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  double get appliedDiscount => _appliedDiscount;
  String? get activeCouponCode => _activeCouponCode;

  List<String> get categories => [
        'All',
        'Horology',
        'Cyber Apparel',
        'Audio',
        'Futuristic EDC',
        'Hardware',
      ];

  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<Product> get featuredProducts =>
      _products.where((p) => p.isFeatured).toList();

  List<Product> get dailyDrops =>
      _products.where((p) => p.isDailyDrop).toList();

  double get cartSubtotal =>
      _cart.fold(0.0, (sum, item) => sum + item.total);

  double get cartTotal {
    final subtotal = cartSubtotal;
    final discounted = subtotal * (1.0 - _appliedDiscount);
    return (discounted > 0 ? discounted : 0.0);
  }

  int get cartItemCount =>
      _cart.fold(0, (sum, item) => sum + item.quantity);

  Product getProductById(String id) =>
      _products.firstWhere((p) => p.id == id, orElse: () => _products.first);

  bool isFavorite(String productId) => _favorites.contains(productId);

  void toggleFavorite(String productId) {
    if (_favorites.contains(productId)) {
      _favorites.remove(productId);
    } else {
      _favorites.add(productId);
    }
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

  void addProduct(Product product) {
    _products.add(product);
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

  void addToCart(Product product, int quantity) {
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

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _appliedDiscount = 0.0;
    _activeCouponCode = null;
    notifyListeners();
  }

  bool applyCoupon(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'ORA20' || clean == 'ARTEFAKT') {
      _appliedDiscount = 0.20; // 20% discount
      _activeCouponCode = clean;
      notifyListeners();
      return true;
    } else if (clean == 'VIP50') {
      _appliedDiscount = 0.50; // 50% VIP discount
      _activeCouponCode = clean;
      notifyListeners();
      return true;
    }
    return false;
  }

  void placeOrder() {
    if (_cart.isEmpty) return;
    final order = Order(
      id: 'MM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: List.from(_cart),
      total: cartTotal,
      date: DateTime.now(),
      status: 'Processing',
    );
    _orders.insert(0, order);
    clearCart();
  }
}

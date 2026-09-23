import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class StoreProvider extends ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: '1',
      title: 'Phone X',
      price: 549.0,
      category: 'smartphones',
      description: '6.1-inch display, 128 GB storage, dual camera.',
      icon: Icons.smartphone,
      color: const Color(0xFFDCE4F5),
    ),
    Product(
      id: '2',
      title: 'Headphones',
      price: 89.0,
      category: 'audio',
      description: 'Wireless over-ear headphones with noise cancellation.',
      icon: Icons.headphones,
      color: const Color(0xFFD6EFE3),
    ),
    Product(
      id: '3',
      title: 'T-shirt',
      price: 15.0,
      category: 'clothing',
      description: '100% cotton, comfortable fit.',
      icon: Icons.checkroom,
      color: const Color(0xFFF8E0D5),
    ),
    Product(
      id: '4',
      title: 'Laptop',
      price: 899.0,
      category: 'computers',
      description: '14-inch, 16 GB RAM, 512 GB SSD.',
      icon: Icons.laptop,
      color: const Color(0xFFE5DAF5),
    ),
    Product(
      id: '5',
      title: 'Camera',
      price: 320.0,
      category: 'photography',
      description: '24 MP DSLR with 18-55mm lens.',
      icon: Icons.camera_alt,
      color: const Color(0xFFE0EBD6),
    ),
    Product(
      id: '6',
      title: 'Backpack',
      price: 42.0,
      category: 'accessories',
      description: 'Water-resistant, 25L capacity.',
      icon: Icons.backpack,
      color: const Color(0xFFF5D6E0),
    ),
  ];

  final List<CartItem> _cart = [];

  List<Product> get products => _products;
  List<CartItem> get cart => _cart;

  double get cartTotal =>
      _cart.fold(0.0, (sum, item) => sum + item.total);

  int get cartItemCount =>
      _cart.fold(0, (sum, item) => sum + item.quantity);

  Product getProductById(String id) =>
      _products.firstWhere((p) => p.id == id);

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

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }
}
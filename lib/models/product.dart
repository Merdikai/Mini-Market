import 'package:flutter/material.dart';

class Product {
  final String id;
  String sku;
  String barcode;
  String title;
  double price;
  double costPrice;
  String category;
  String description;
  String imageUrl;
  final IconData icon;
  final Color color;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isDailyDrop;
  int stock;
  int minStock;
  String unit;
  double taxRate;
  final String? badge;
  final Map<String, String> specs;

  Product({
    required this.id,
    this.sku = '',
    this.barcode = '',
    required this.title,
    required this.price,
    this.costPrice = 0.0,
    required this.category,
    required this.description,
    this.imageUrl = '',
    this.icon = Icons.shopping_bag_outlined,
    this.color = const Color(0xFF00D2E0),
    this.rating = 4.8,
    this.reviewCount = 64,
    this.isFeatured = false,
    this.isDailyDrop = false,
    this.stock = 25,
    this.minStock = 5,
    this.unit = 'pcs',
    this.taxRate = 0.08,
    this.badge,
    this.specs = const {},
  });

  bool get isLowStock => stock <= minStock && stock > 0;
  bool get isOutOfStock => stock <= 0;

  double get marginPercentage {
    if (price <= 0) return 0.0;
    return ((price - costPrice) / price) * 100;
  }

  Product copyWith({
    String? id,
    String? sku,
    String? barcode,
    String? title,
    double? price,
    double? costPrice,
    String? category,
    String? description,
    String? imageUrl,
    IconData? icon,
    Color? color,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    bool? isDailyDrop,
    int? stock,
    int? minStock,
    String? unit,
    double? taxRate,
    String? badge,
    Map<String, String>? specs,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      title: title ?? this.title,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isDailyDrop: isDailyDrop ?? this.isDailyDrop,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      taxRate: taxRate ?? this.taxRate,
      badge: badge ?? this.badge,
      specs: specs ?? this.specs,
    );
  }
}

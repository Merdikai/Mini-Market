import 'package:flutter/material.dart';

class Product {
  final String id;
  String title;
  double price;
  String category;
  String description;
  final IconData icon;
  final Color color;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isDailyDrop;
  final int stock;
  final String? badge;
  final Map<String, String> specs;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.description,
    required this.icon,
    required this.color,
    this.rating = 4.9,
    this.reviewCount = 128,
    this.isFeatured = false,
    this.isDailyDrop = false,
    this.stock = 15,
    this.badge,
    this.specs = const {},
  });
}

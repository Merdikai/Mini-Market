import 'package:flutter/material.dart';

class ProductCategory {
  final String id;
  final String name;
  final String slug;
  final IconData icon;
  final Color color;
  final String imageUrl;
  final int itemCount;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.color,
    required this.imageUrl,
    this.itemCount = 0,
  });
}

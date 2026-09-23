import 'package:flutter/material.dart';

class Product {
  final String id;
  String title;
  double price;
  String category;
  String description;
  final IconData icon;
  final Color color;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.description,
    required this.icon,
    required this.color,
  });
}
import 'package:flutter/material.dart';

enum Categories {
  fruit,
  dairy,
  meat,
  vegetables,
  spices,
  sweets,
  hygiene,
  carbs,
  convenience,
  other,
}

class Category {
  final String type;
  final Color categoryColor;

  const Category(this.type, this.categoryColor);
}

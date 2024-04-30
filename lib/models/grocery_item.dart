import 'package:shoppingapp/models/category.dart';

class GroceryItem {
  final String id;
  final String name;
  final num quantity;
  final Category category;

  const GroceryItem({required this.id, required this.name, required this.quantity, required this.category});
}

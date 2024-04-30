import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoppingapp/data/categories.dart';
import 'package:shoppingapp/models/grocery_item.dart';
import 'package:shoppingapp/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  late List<GroceryItem> groceries = [];
  var isLoading = true;

  void _addItem() {
    Navigator.of(context).push(MaterialPageRoute(builder: ((context) => const NewItem()))).then((value) => _loadItems());
  }

  void _loadItems() async {
    final url = Uri.https('flutterlearn-681ce-default-rtdb.europe-west1.firebasedatabase.app', 'shopping-list.json');
    final response = await http.get(url);
    if (response.statusCode < 400) {
      if (response.body != 'null') {
        final Map<String, dynamic> listData = json.decode(response.body);
        final List<GroceryItem> loadedItems = [];
        for (final item in listData.entries) {
          final category = categories.entries.firstWhere((catItem) => item.value['category'] == catItem.value.type).value;
          loadedItems.add(GroceryItem(id: item.key, name: item.value['name'], quantity: item.value['quantity'], category: category));
        }
        setState(() {
          groceries = loadedItems;
          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network Error!')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _removeItem(GroceryItem item) {
    final url = Uri.https('flutterlearn-681ce-default-rtdb.europe-west1.firebasedatabase.app', 'shopping-list/${item.id}.json');
    http.delete(url);
    setState(() {
      groceries.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: !isLoading
          ? groceries.isNotEmpty
              ? ListView.builder(
                  itemCount: groceries.length,
                  itemBuilder: (ctx, index) => Dismissible(
                    key: ValueKey(groceries[index]),
                    onDismissed: (direction) {
                      _removeItem(groceries[index]);
                    },
                    child: ListTile(
                      title: Text(groceries[index].name),
                      leading: Container(
                        width: 24,
                        height: 24,
                        color: groceries[index].category.categoryColor,
                      ),
                      trailing: Text(
                        groceries[index].quantity.toString(),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No Items yet.'),
                      TextButton(
                        onPressed: _addItem,
                        child: const Text('Add new Item'),
                      )
                    ],
                  ),
                )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

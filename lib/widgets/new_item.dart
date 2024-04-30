import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoppingapp/data/categories.dart';
import 'package:shoppingapp/models/category.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _chosenCategory = categories[Categories.vegetables]!;
  var isSending = false;

  void _saveItem() {
    setState(() {
      isSending = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.https('flutterlearn-681ce-default-rtdb.europe-west1.firebasedatabase.app', 'shopping-list.json');
      http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(
              {
                'name': _enteredName,
                'quantity': _enteredQuantity,
                'category': _chosenCategory.type,
              },
            ),
          )
          .then(
            (response) => {
              if (response.statusCode < 400)
                {Navigator.of(context).pop()}
              else
                {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network Error!'))),
                }
            },
          );
    } else {
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
                validator: (value) {
                  if (value == null || value.isEmpty || value.trim().length <= 1 || value.trim().length >= 50) {
                    return 'Must be between 1 and 50 characters long.';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _enteredName = newValue!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(label: Text('Quantity')),
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty || int.tryParse(value) == null || int.tryParse(value)! <= 0) {
                          return 'Must be a valid positive number.';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enteredQuantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _chosenCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.categoryColor,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.type)
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        setState(() {
                          _chosenCategory = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        if (!isSending) {
                          _formKey.currentState!.reset();
                          setState(() {
                            _chosenCategory = categories[Categories.vegetables]!;
                          });
                        }
                      },
                      child: const Text('Reset')),
                  ElevatedButton(
                      onPressed: () {
                        if (!isSending) {
                          _saveItem();
                        }
                      },
                      child: isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Add Item')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

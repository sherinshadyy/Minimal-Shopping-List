import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  String? _selectedCategory;
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? cats = prefs.getStringList('categories');
    setState(() {
      _categories = cats ?? [];
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories[0];
      }
    });
  }

  Future<void> _saveItem() async {
    String itemName = _itemNameController.text.trim();
    String quantity = _quantityController.text.trim();

    if (_selectedCategory == null) {
      _showMessage('Please select a category');
      return;
    }
    if (itemName.isEmpty) {
      _showMessage('Please enter an item name');
      return;
    }
    if (quantity.isEmpty) {
      _showMessage('Please enter quantity');
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // Items stored as JSON stringified Map<String, List<Map>>
    String? itemsJson = prefs.getString('items');
    Map<String, dynamic> itemsMap = {};
    if (itemsJson != null) {
      itemsMap = json.decode(itemsJson);
    }

    // Convert dynamic to List<Map>
    List<dynamic> categoryItemsDynamic = itemsMap[_selectedCategory] ?? [];
    List<Map<String, dynamic>> categoryItems =
        categoryItemsDynamic.cast<Map<String, dynamic>>();

    categoryItems.add({
      'name': itemName,
      'quantity': quantity,
      'notes': _notesController.text.trim(),
      'done': false,
    });

    itemsMap[_selectedCategory!] = categoryItems;

    await prefs.setString('items', json.encode(itemsMap));

    _showMessage('Item added successfully!');

    _itemNameController.clear();
    _quantityController.clear();
    _notesController.clear();

    Navigator.pop(context);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        backgroundColor: const Color(0xFF5B7B3F),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF93C572), Color(0xFF5B7B3F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
              items: _categories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(
                hintText: 'Item Name',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.shopping_bag),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Quantity',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.format_list_numbered),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Notes (optional)',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF7E48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Add Item',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

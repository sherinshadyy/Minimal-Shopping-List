import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DetailScreen extends StatefulWidget {
  final String category;
  final Map<String, dynamic> item;
  final int index;

  const DetailScreen({
    super.key,
    required this.category,
    required this.item,
    required this.index,
  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  bool done = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item['name']);
    _quantityController = TextEditingController(text: widget.item['quantity']);
    _notesController = TextEditingController(text: widget.item['notes']);
    done = widget.item['done'] ?? false;
  }

  Future<void> _saveChanges() async {
    String name = _nameController.text.trim();
    String quantity = _quantityController.text.trim();

    if (name.isEmpty) {
      _showMessage('Item name cannot be empty');
      return;
    }
    if (quantity.isEmpty) {
      _showMessage('Quantity cannot be empty');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? itemsJson = prefs.getString('items');

    if (itemsJson == null) return;

    Map<String, dynamic> itemsMap = json.decode(itemsJson);

    List<dynamic> categoryItems = itemsMap[widget.category];
    if (categoryItems.length <= widget.index) return;

    categoryItems[widget.index] = {
      'name': name,
      'quantity': quantity,
      'notes': _notesController.text.trim(),
      'done': done,
    };

    itemsMap[widget.category] = categoryItems;

    await prefs.setString('items', json.encode(itemsMap));

    _showMessage('Item updated');

    Navigator.pop(context, true); // return true to indicate update
  }

  Future<void> _deleteItem() async {
    final prefs = await SharedPreferences.getInstance();
    String? itemsJson = prefs.getString('items');

    if (itemsJson == null) return;

    Map<String, dynamic> itemsMap = json.decode(itemsJson);

    List<dynamic> categoryItems = itemsMap[widget.category];

    categoryItems.removeAt(widget.index);

    itemsMap[widget.category] = categoryItems;

    await prefs.setString('items', json.encode(itemsMap));

    _showMessage('Item deleted');

    Navigator.pop(context, true); // indicate update
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: const Color(0xFF5B7B3F),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Item'),
                  content: const Text('Are you sure you want to delete this item?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _deleteItem();
              }
            },
          )
        ],
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
            TextField(
              controller: _nameController,
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
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Mark as done', style: TextStyle(color: Colors.white, fontSize: 16)),
                Switch(
                  value: done,
                  activeColor: const Color(0xFFEF7E48),
                  onChanged: (val) {
                    setState(() {
                      done = val;
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF7E48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Save Changes',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'detail_screen.dart';

class ViewItemsScreen extends StatefulWidget {
  const ViewItemsScreen({super.key});

  @override
  _ViewItemsScreenState createState() => _ViewItemsScreenState();
}

class _ViewItemsScreenState extends State<ViewItemsScreen> {
  Map<String, List<dynamic>> itemsMap = {};
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    String? itemsJson = prefs.getString('items');

    if (itemsJson != null) {
      Map<String, dynamic> decoded = json.decode(itemsJson);
      Map<String, List<dynamic>> map = {};

      decoded.forEach((key, value) {
        map[key] = List<dynamic>.from(value);
      });

      setState(() {
        itemsMap = map;
        categories = map.keys.toList();
      });
    } else {
      setState(() {
        itemsMap = {};
        categories = [];
      });
    }
  }

  void _refresh() {
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Items'),
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
        child: categories.isEmpty
            ? const Center(
                child: Text(
                  'No items found. Add some!',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  String category = categories[index];
                  List<dynamic> categoryItems = itemsMap[category] ?? [];

                  return ExpansionTile(
                    title: Text(
                      category,
                      style: const TextStyle(
                          color: Color(0xFFEF7E48),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    children: categoryItems.isEmpty
                        ? [
                            const ListTile(
                              title: Text(
                                'No items in this category',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          ]
                        : categoryItems.map((item) {
                            return ListTile(
                              title: Text(item['name']),
                              subtitle: Text(
                                  'Qty: ${item['quantity']} - ${item['notes']}'),
                              trailing: Icon(
                                item['done']
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                color: item['done']
                                    ? Colors.greenAccent
                                    : Colors.white70,
                              ),
                              onTap: () async {
                                // Navigate to Detail screen to edit/view
                                bool? updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailScreen(
                                        category: category,
                                        item: Map<String, dynamic>.from(item),
                                        index: categoryItems.indexOf(item)),
                                  ),
                                );
                                if (updated == true) {
                                  _refresh();
                                }
                              },
                            );
                          }).toList(),
                  );
                },
              ),
      ),
    );
  }
}

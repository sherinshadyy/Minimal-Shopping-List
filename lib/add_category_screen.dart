import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _categoryController = TextEditingController();

  Future<void> _saveCategory() async {
    String newCategory = _categoryController.text.trim();
    if (newCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category name cannot be empty')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> categories = prefs.getStringList('categories') ?? [];

    if (categories.contains(newCategory)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category already exists')));
      return;
    }

    categories.add(newCategory);
    await prefs.setStringList('categories', categories);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category "$newCategory" added successfully')));

    _categoryController.clear();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
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
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                hintText: 'Enter category name',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF7E48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Save Category',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

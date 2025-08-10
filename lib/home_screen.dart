import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_info_screen.dart';
import 'detail_screen.dart'; // Your existing detail screen
import 'report_screen.dart';
import 'add_category_screen.dart';
import 'add_item_screen.dart';
import 'view_items_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String welcomeMessage = "";

  @override
  void initState() {
    super.initState();
    welcomeMessage = "Hello, ${widget.username}!";
  }

  void _navigateToAccountInfo() {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountInfoScreen(username: widget.username),
      ),
    );
  }

  void _navigateToReport() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => ReportScreen()));
  }

  void _navigateToItemDetails() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ViewItemsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groceasy'),
        backgroundColor: const Color(0xFF5B7B3F),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Add settings navigation or functionality here
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Settings tapped')));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF93C572),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF5B7B3F)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 64,
                      color: Color(0xFFFFA500),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Welcome to Groceasy',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text(
                  'Account Info',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: _navigateToAccountInfo,
              ),
              ListTile(
                leading: const Icon(Icons.list_alt, color: Colors.white),
                title: const Text(
                  'Item Details',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: _navigateToItemDetails,
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.white),
                title: const Text(
                  'Report',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: _navigateToReport,
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text(
                  'Settings',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings tapped')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF93C572), Color(0xFF5B7B3F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo added here
                Image.asset('assests/logo.png', height: 100, width: 100),
                const SizedBox(height: 20),

                Text(
                  welcomeMessage,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF7E48),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Manage your grocery diary",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddCategoryScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF7E48),
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Add Category',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    List<String>? cats = prefs.getStringList('categories');
                    if (cats == null || cats.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please add at least one category before adding items',
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddItemScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF7E48),
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Add Item',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ViewItemsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF7E48),
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'View Items',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

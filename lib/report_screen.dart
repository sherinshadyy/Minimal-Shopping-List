import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _addedThisWeek = 0;
  int _completedThisWeek = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString('items');

    if (itemsJson == null) {
      setState(() {
        _addedThisWeek = 0;
        _completedThisWeek = 0;
        _loading = false;
      });
      return;
    }

    final Map<String, dynamic> itemsMap = json.decode(itemsJson);

    final DateTime now = DateTime.now();
    final DateTime weekAgo = now.subtract(const Duration(days: 7));

    int added = 0;
    int completed = 0;

    itemsMap.forEach((category, itemList) {
      for (var item in itemList) {
        // Date parsing - fallback to now if invalid
        DateTime dateAdded;
        if (item.containsKey('dateAdded')) {
          try {
            dateAdded = DateTime.parse(item['dateAdded']);
          } catch (_) {
            dateAdded = now;
          }
        } else {
          dateAdded = now;
        }

        if (dateAdded.isAfter(weekAgo)) {
          added++;
          if (item['done'] == true) {
            completed++;
          }
        }
      }
    });

    setState(() {
      _addedThisWeek = added;
      _completedThisWeek = completed;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF5B7B3F);
    final Color accentOrange = const Color(0xFFEF7E48);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Report'),
        backgroundColor: primaryGreen,
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
        child: Center(
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insert_chart, size: 80, color: accentOrange),
                    const SizedBox(height: 30),
                    Text(
                      'Groceries Added This Week: $_addedThisWeek',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Groceries Completed This Week: $_completedThisWeek',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

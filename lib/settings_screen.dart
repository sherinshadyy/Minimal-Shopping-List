import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Center(
        child: Text(
          'Settings options coming soon!',
          style: TextStyle(fontSize: 18, color: Colors.green.shade700),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AccountInfoScreen extends StatelessWidget {
  final String username;
  const AccountInfoScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Info'),
        backgroundColor: const Color(0xFF5B7B3F),
      ),
      body: Center(
        child: Text(
          'Here you can change name/password for $username',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

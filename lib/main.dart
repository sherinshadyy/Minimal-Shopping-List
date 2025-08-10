import 'package:flutter/material.dart';

import 'login_screen.dart';

void main() {
  runApp(GroceasyApp());
}

class GroceasyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

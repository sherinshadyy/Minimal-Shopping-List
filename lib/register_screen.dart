import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  double _age = 25;
  String? _country;
  List<String> _countries = [];
  bool _isLoadingCountries = true; // <-- loading flag

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    setState(() {
      _isLoadingCountries = true;
    });

    try {
      final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<String> fetchedCountries = data
            .map((country) => country['name']['common'] as String)
            .toList();
        fetchedCountries.sort();

        setState(() {
          _countries = fetchedCountries;
          _country = _countries.isNotEmpty ? _countries[0] : null;
        });
      } else {
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      List<String> fallbackCountries = [
        'United States',
        'Canada',
        'Egypt',
        'UAE',
        'United Kingdom',
        'Australia',
        'India',
        'Germany',
        'France',
        'Japan',
        'China',
        'Brazil',
        'South Africa'
      ];
      fallbackCountries.sort();

      setState(() {
        _countries = fallbackCountries;
        _country = _countries.isNotEmpty ? _countries[0] : null;
      });
    } finally {
      setState(() {
        _isLoadingCountries = false;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    String newUsername = _usernameController.text.trim();

    List<String> usersList = prefs.getStringList('users') ?? [];

    bool usernameExists = usersList.any((userJson) {
      final userMap = json.decode(userJson);
      return userMap['username'] == newUsername;
    });

    if (usernameExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username already exists. Please choose another.')),
      );
      return;
    }

    Map<String, dynamic> newUser = {
      'name': _nameController.text.trim(),
      'username': newUsername,
      'password': _passwordController.text.trim(),
      'age': _age.round(),
      'country': _country,
    };

    usersList.add(json.encode(newUser));
    await prefs.setStringList('users', usersList);

    await prefs.setString('logged_in_username', newUsername);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(username: newUsername),
      ),
    );
  }

  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B7B3F), // pistachio dark
        title: const Text(
          'Register',
          style: TextStyle(
            fontSize: 28,
            color: Color(0xFFEF7E48), // orange
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFEF7E48)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF93C572), Color(0xFF5B7B3F)], // pistachio gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField(_nameController, 'Name', Icons.person, (val) => _validateNotEmpty(val, 'Name')),
                  const SizedBox(height: 15),
                  _buildInputField(_usernameController, 'Username', Icons.alternate_email, (val) => _validateNotEmpty(val, 'Username')),
                  const SizedBox(height: 15),
                  _buildPasswordField(_passwordController, 'Password', Icons.lock, (val) => _validateNotEmpty(val, 'Password')),
                  const SizedBox(height: 15),
                  Text('Age: ${_age.round()}', style: const TextStyle(color: Color(0xFFEF7E48), fontSize: 18)),
                  Slider(
                    value: _age,
                    min: 15,
                    max: 100,
                    divisions: 85,
                    activeColor: const Color(0xFFEF7E48),
                    inactiveColor: const Color(0xFFB7C798),
                    onChanged: (double value) {
                      setState(() {
                        _age = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),

                  // Show loading indicator or dropdown:
                  _isLoadingCountries
                      ? const Center(child: CircularProgressIndicator())
                      : _buildCountryDropdown(),

                  if (_country == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text('Country is required', style: TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 25),
                  Center(
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF7E48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 16),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, IconData icon, String? Function(String?) validator) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF5B7B3F)),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint, IconData icon, String? Function(String?) validator) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF5B7B3F)),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: DropdownButtonFormField<String>(
        value: _country,
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF5B7B3F)),
        isExpanded: true,
        decoration: const InputDecoration(border: InputBorder.none),
        items: _countries.map((value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
        onChanged: (newValue) {
          setState(() {
            _country = newValue!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a country';
          }
          return null;
        },
      ),
    );
  }
}

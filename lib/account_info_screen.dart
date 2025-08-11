import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountInfoScreen extends StatefulWidget {
  final String username;

  const AccountInfoScreen({Key? key, required this.username}) : super(key: key);

  @override
  _AccountInfoScreenState createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  double _age = 25;
  String? _country;

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  List<String> _countries = [
    'United States', 'Canada', 'Egypt', 'UAE', 'United Kingdom',
    'Australia', 'India', 'Germany', 'France', 'Japan', 'China',
    'Brazil', 'South Africa'
  ];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _loadUserInfo();
    _countries.sort();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _age = prefs.getInt('age')?.toDouble() ?? 25;
      _country = prefs.getString('country') ?? _countries.first;
      _usernameController.text = prefs.getString('username') ?? widget.username;
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text.trim());
    await prefs.setInt('age', _age.round());
    if (_country != null) {
      await prefs.setString('country', _country!);
    }
    await prefs.setString('username', _usernameController.text.trim());
    if (_passwordController.text.trim().isNotEmpty) {
      await prefs.setString('password', _passwordController.text.trim());
    }

    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account info updated successfully')),
    );

    Navigator.pop(context, _usernameController.text.trim()); // Return new username
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF5B7B3F);
    final Color accentOrange = const Color(0xFFEF7E48);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Info'),
        backgroundColor: primaryGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/logo.png'),
                ),
              ),
              const SizedBox(height: 30),

              // Name
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white24,
                  prefixIcon: const Icon(Icons.person, color: Colors.white70),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 20),

              // Username
              TextFormField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white24,
                  prefixIcon: const Icon(Icons.alternate_email, color: Colors.white70),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Username cannot be empty' : null,
              ),
              const SizedBox(height: 20),

              // Password
              TextFormField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'New Password (leave blank to keep unchanged)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white24,
                  prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none),
                ),
                obscureText: true,
                validator: (val) {
                  if (val != null && val.isNotEmpty && val.length < 6) {
                    return 'Password should be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Age slider & label
              Text('Age: ${_age.round()}',
                  style: const TextStyle(color: Color(0xFFEF7E48), fontSize: 18)),
              Slider(
                value: _age,
                min: 15,
                max: 100,
                divisions: 85,
                activeColor: accentOrange,
                inactiveColor: const Color(0xFFB7C798),
                onChanged: (double value) {
                  setState(() {
                    _age = value;
                  });
                },
              ),
              const SizedBox(height: 10),

              // Country dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: DropdownButtonFormField<String>(
                  value: _country,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
                  dropdownColor: primaryGreen,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: _countries.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
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
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _loading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

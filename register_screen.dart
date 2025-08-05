// lib/screens/register_screen.dart (CORRECTED)

import 'package:flutter/material.dart';
import 'package:smart_farming_app/screens/home_dashboard.dart';
import 'package:smart_farming_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'farmer';
  bool _isLoading = false;

  void _register() async {
    setState(() => _isLoading = true);
    User? user = await _auth.registerWithEmail(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      _selectedRole,
    );

    // --- FIX IS HERE ---
    if (!mounted) return;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (c) => HomeDashboard(userName: user.displayName ?? 'Farmer')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to register. The email might already be in use.')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // UI remains the same...
     return Scaffold(
       appBar: AppBar(title: const Text('Register')),
       body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _isLoading ? const CircularProgressIndicator() : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
                const SizedBox(height: 16),
                TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 16),
                TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("I am a: "),
                    DropdownButton<String>(
                      value: _selectedRole,
                      items: const [
                        DropdownMenuItem(value: 'farmer', child: Text('Farmer')),
                        DropdownMenuItem(value: 'expert', child: Text('Expert')),
                      ],
                      onChanged: (value) => setState(() => _selectedRole = value!),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: _register, child: const Text('Register')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
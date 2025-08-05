// lib/screens/login_screen.dart (FINAL MANUAL UI VERSION)

import 'package:flutter/material.dart';
import 'package:smart_farming_app/screens/home_dashboard.dart';
import 'package:smart_farming_app/screens/register_screen.dart'; // We will use our manual register screen
import 'package:smart_farming_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart'; // For translations

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter both email and password.')));
      return;
    }
    setState(() => _isLoading = true);
    User? user = await _auth.signInWithEmail(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (c) => HomeDashboard(userName: user.displayName ?? 'Farmer')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to sign in. Please check your credentials.')));
    }
    if (mounted) setState(() => _isLoading = false);
  }
  
  void _loginWithGoogle() async {
     setState(() => _isLoading = true);
     User? user = await _auth.signInWithGoogle();
     if (!mounted) return;
     if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (c) => HomeDashboard(userName: user.displayName ?? 'Farmer')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign in was cancelled or failed.')));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _isLoading 
              ? const CircularProgressIndicator() 
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.eco, size: 80, color: Colors.green),
                    const SizedBox(height: 20),
                    Text('login'.tr(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 40),
                    TextField(controller: _emailController, decoration: InputDecoration(labelText: 'email'.tr())),
                    const SizedBox(height: 16),
                    TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'password'.tr()), obscureText: true),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _login, 
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text('login'.tr())
                    ),
                    const SizedBox(height: 16),
                    // ======== THIS IS WHERE YOU PASTE THE CLIENT ID ========
                    // This button will not be visible, it's used by the Google Sign-In package.
                    // The actual visible button would be custom styled. For now, we use a standard one.
                    ElevatedButton.icon(
                      onPressed: _loginWithGoogle, 
                      icon: const Icon(Icons.g_mobiledata), // Example Icon
                      label: const Text('Sign in with Google'),
                      // The GoogleSignIn class we use in auth_service.dart will automatically
                      // pick up the necessary configuration from the google-services.json file.
                      // We don't need to explicitly pass the client ID here in this manual setup.
                    ),
                    // ========================================================
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('no_account'.tr()),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (c) => const RegisterScreen())),
                          child: Text('register'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ),
                      ],
                    ),
                  ],
              ),
          ),
        ),
      ),
    );
  }
}
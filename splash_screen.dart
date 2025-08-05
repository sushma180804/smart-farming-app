// lib/screens/splash_screen.dart (Ensure this is your code)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_farming_app/screens/home_dashboard.dart';
import 'package:smart_farming_app/screens/login_screen.dart';
import 'package:smart_farming_app/screens/language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), _checkUserFlow);
  }

  void _checkUserFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final bool languageSelected = prefs.getBool('language_selected') ?? false;

    if (!mounted) return;

    if (!languageSelected) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
      );
      return;
    }

    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      final String userName = prefs.getString('user_name') ?? 'Farmer';
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeDashboard(userName: userName)),
      );
    } else {
      // This is the key: it goes to the LoginScreen which now acts as the AuthGate
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'app_name'.tr(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
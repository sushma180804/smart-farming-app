// lib/main.dart (THE DEFINITIVE AND CORRECT VERSION)

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:smart_farming_app/screens/splash_screen.dart';

// This is our custom class to override default labels.
class LabelOverrides extends DefaultLocalizations {
  const LabelOverrides();

  @override
  String get emailInputLabel => 'Enter your email';

  @override
  String get passwordInputLabel => 'Enter your password';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Manual setup
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      // This is our list of supported languages
      supportedLocales: const [Locale('en'), Locale('hi'), Locale('te')],
      path: 'assets/locales',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ======== THE FIX IS HERE ========
      // Use the delegates and locales provided by the EasyLocalization context
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale, // This is the master switch for the language
      // =================================

      title: 'Smart Farming App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
// lib/screens/home_dashboard.dart (COMPLETE AND VERIFIED)

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_farming_app/components/dashboard_card.dart';

// All necessary screen imports
import 'package:smart_farming_app/screens/login_screen.dart';
import 'package:smart_farming_app/screens/settings_screen.dart';
import 'package:smart_farming_app/screens/weather_screen.dart';
import 'package:smart_farming_app/screens/marketplace_screen.dart';
import 'package:smart_farming_app/screens/hire_workers_screen.dart';
import 'package:smart_farming_app/screens/my_questions_screen.dart';
import 'package:smart_farming_app/screens/experts_list_screen.dart';
import 'package:smart_farming_app/screens/soil_analysis_screen.dart';
import 'package:smart_farming_app/screens/smart_alerts_screen.dart';

class HomeDashboard extends StatefulWidget {
  final String userName;

  const HomeDashboard({
    super.key,
    required this.userName,
  });

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  void _logout() async {
    // This function is correct and does not need changes.
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('logout'.tr()),
          content: Text('logout_confirm'.tr()),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('no'.tr())),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('yes'.tr())),
          ],
        );
      },
    );
    if (confirm == true && mounted) {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('user_name');
      await prefs.remove('auth_token');
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home_dashboard'.tr()),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'settings'.tr(),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
            if (mounted) {
              setState(() {});
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'logout'.tr(),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              '${'welcome'.tr()} ${widget.userName}!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  DashboardCard(
                    icon: Icons.wb_sunny_outlined,
                    title: 'weather'.tr(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const WeatherScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.grass_outlined,
                    title: 'soil_analysis'.tr(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SoilAnalysisScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.people_alt_outlined,
                    title: 'farmers_workers'.tr(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const HireWorkersScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.shopping_cart_outlined,
                    title: 'marketplace'.tr(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const MarketplaceScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.question_answer_outlined,
                    title: 'expert_help'.tr(), // This is the "Ask Expert / My Questions" card
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const MyQuestionsScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.support_agent_outlined,
                    title: 'expert_corner'.tr(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ExpertsListScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.notifications_active_outlined,
                    title: 'smart_alerts'.tr(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SmartAlertsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
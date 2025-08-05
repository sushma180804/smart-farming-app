// lib/screens/smart_alerts_screen.dart (REPLACE ENTIRE FILE)

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smart_farming_app/data/alert_data.dart';

class SmartAlertsScreen extends StatelessWidget {
  const SmartAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('smart_alerts'.tr()),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: alertData.isEmpty
          ? Center(child: Text('no_alerts'.tr()))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: alertData.length,
              itemBuilder: (context, index) {
                final alert = alertData[index];
                final timeAgo = DateFormat.yMMMd().add_jm().format(alert.timestamp);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      // ======== THE FIX IS HERE ========
                      // Old way: backgroundColor: alert.iconColor.withOpacity(0.1),
                      // New, correct way:
                      backgroundColor: alert.iconColor.withAlpha(25), // 25 is approx 10% opacity
                      // ===================================
                      child: Icon(alert.icon, color: alert.iconColor),
                    ),
                    title: Text(
                      alert.titleKey.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(alert.bodyKey.tr()),
                        const SizedBox(height: 8),
                        Text(
                          timeAgo,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
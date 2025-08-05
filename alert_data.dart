// lib/data/alert_data.dart (NEW FILE)

import 'package:flutter/material.dart';

class SmartAlert {
  final String titleKey;
  final String bodyKey;
  final IconData icon;
  final Color iconColor;
  final DateTime timestamp;

  SmartAlert({
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
    required this.iconColor,
    required this.timestamp,
  });
}

// Our pre-defined list of alerts.
// In a real app, this data would come from a backend or push notification.
final List<SmartAlert> alertData = [
  SmartAlert(
    titleKey: 'alert_irrigation_title',
    bodyKey: 'alert_irrigation_body',
    icon: Icons.water_drop,
    iconColor: Colors.blue,
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  SmartAlert(
    titleKey: 'alert_pesticide_title',
    bodyKey: 'alert_pesticide_body',
    icon: Icons.bug_report,
    iconColor: Colors.red,
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
  ),
  SmartAlert(
    titleKey: 'alert_market_title',
    bodyKey: 'alert_market_body',
    icon: Icons.trending_up,
    iconColor: Colors.green,
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
  ),
];
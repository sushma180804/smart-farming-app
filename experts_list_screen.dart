// lib/screens/experts_list_screen.dart (NEW FILE)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpertsListScreen extends StatelessWidget {
  const ExpertsListScreen({super.key});

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch dialer for $phoneNumber')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('experts_list'.tr()),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('experts').orderBy('registeredAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No experts have registered yet.'));
          }

          final experts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: experts.length,
            itemBuilder: (context, index) {
              final expertData = experts[index].data() as Map<String, dynamic>;
              final String name = expertData['name'] ?? 'N/A';
              final String specialization = expertData['specialization'] ?? 'N/A';
              final String phone = expertData['phoneNumber'] ?? '';
              final bool canVisit = expertData['canVisitFields'] ?? false;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const Icon(Icons.psychology_alt, color: Colors.green, size: 40),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(specialization),
                      const SizedBox(height: 4),
                      Text(
                        canVisit ? 'field_visit_available'.tr() : 'field_visit_not_available'.tr(),
                        style: TextStyle(
                          color: canVisit ? Colors.green.shade800 : Colors.orange.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: phone.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.call, color: Colors.blueAccent),
                          tooltip: 'call_now'.tr(),
                          onPressed: () => _makePhoneCall(context, phone),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// lib/screens/hire_workers_screen.dart (REPLACE ENTIRE FILE)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smart_farming_app/screens/my_jobs_screen.dart'; // <-- Import new screen
import 'package:smart_farming_app/screens/post_job_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HireWorkersScreen extends StatelessWidget {
  const HireWorkersScreen({super.key});

  Future<void> _contactFarmer(BuildContext context, String? phoneNumber) async {
    // ... (This function is correct and doesn't need changes) ...
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact number not provided by the farmer.')),
      );
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
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
        title: Text('available_jobs'.tr()),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        // ======== NEW ACTION BUTTON ========
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyJobsScreen()));
            },
            icon: const Icon(Icons.work_history),
            label: Text('my_jobs'.tr()),
          )
        ],
        // ===================================
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('jobs').orderBy('postedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          // ... (Rest of the body code is the same and correct) ...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No jobs have been posted yet.'));
          }

          final jobs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final jobData = jobs[index].data() as Map<String, dynamic>;
              final String title = jobData['title'] ?? 'N/A';
              final String description = jobData['description'] ?? 'No description.';
              final int workersNeeded = jobData['workersNeeded'] ?? 0;
              final double salary = jobData['salaryPerDay']?.toDouble() ?? 0.0;
              final String? contactPhone = jobData['contactPhone'];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(description),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${'workers_needed'.tr()}: $workersNeeded'),
                              Text('${'salary'.tr()}: ${salary.toStringAsFixed(2)}'),
                            ],
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.phone_forwarded),
                            label: Text('contact_farmer'.tr()),
                            onPressed: () => _contactFarmer(context, contactPhone),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const PostJobScreen(),
          ));
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        tooltip: 'post_new_job'.tr(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
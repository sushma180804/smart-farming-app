// lib/screens/workers_portal_screen.dart (NEW FILE)

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_farming_app/screens/post_job_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkersPortalScreen extends StatelessWidget {
  const WorkersPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> jobsStream = FirebaseFirestore.instance
        .collection('jobs')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('farmers_workers'.tr()),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: jobsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return Center(child: Text('no_jobs_available'.tr()));

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return JobCard(data: data);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PostJobScreen())),
        label: Text('post_new_job'.tr()),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const JobCard({super.key, required this.data});

  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(launchUri)) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch phone dialer')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Timestamp startDate = data['startDate'] ?? Timestamp.now();
    final String formattedDate = DateFormat.yMMMd().format(startDate.toDate());
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['jobTitle'] ?? 'No Title', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Chip(
              label: Text('${data['wages'] ?? 'N/A'}'),
              backgroundColor: Colors.green.shade100,
            ),
            const SizedBox(height: 8),
            Text.rich(TextSpan(children: [
              const WidgetSpan(child: Icon(Icons.group, size: 16)),
              TextSpan(text: ' ${'workers_needed'.tr()}: ${data['workersNeeded'] ?? 0}'),
            ])),
            Text.rich(TextSpan(children: [
              const WidgetSpan(child: Icon(Icons.location_on, size: 16)),
              TextSpan(text: ' Location: ${data['location'] ?? 'N/A'}'),
            ])),
            Text.rich(TextSpan(children: [
              const WidgetSpan(child: Icon(Icons.calendar_today, size: 16)),
              TextSpan(text: ' Starts on: $formattedDate'),
            ])),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text('${'posted_by'.tr()}: ${data['postedBy'] ?? 'Unknown'}')),
                ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(data['contactNumber'], context),
                  icon: const Icon(Icons.call),
                  label: Text('contact_farmer'.tr()),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
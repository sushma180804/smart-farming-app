// lib/screens/expert_questions_screen.dart (REPLACE ENTIRE FILE)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_farming_app/screens/reply_to_question_screen.dart'; // <-- Import the new screen

class ExpertQuestionsScreen extends StatelessWidget {
  const ExpertQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> requestsStream = FirebaseFirestore.instance
        .collection('help_requests')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Questions'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: requestsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No questions have been submitted yet.'));

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              // Add a chip to show the status of the request
              final status = data['status'] ?? 'submitted';

              return ListTile(
                title: Text(data['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('From: ${data['userName']}'),
                // Show a different icon based on whether the question has been replied to
                trailing: Chip(
                  label: Text(status, style: const TextStyle(color: Colors.white)),
                  backgroundColor: status == 'replied' ? Colors.green : Colors.orange,
                ),
                onTap: () {
                  // ======== THE NAVIGATION LOGIC IS NOW ENABLED ========
                  Navigator.of(context).push(MaterialPageRoute(
                    // Pass the specific document to the reply screen
                    builder: (context) => ReplyToQuestionScreen(requestDoc: document),
                  ));
                  // ===================================================
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
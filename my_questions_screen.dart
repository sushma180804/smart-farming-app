// lib/screens/my_questions_screen.dart (REPLACE ENTIRE FILE)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smart_farming_app/screens/ask_question_screen.dart';

class MyQuestionsScreen extends StatelessWidget {
  const MyQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('my_questions'.tr())),
        body: const Center(child: Text('Please log in to see your questions.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('my_questions'.tr()),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Query the 'help_requests' collection and filter by the current user's ID
        stream: FirebaseFirestore.instance
            .collection('help_requests')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('postedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('no_questions_asked'.tr()));
          }

          final questions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final questionData = questions[index].data() as Map<String, dynamic>;
              final String title = questionData['title'] ?? 'No Title';
              final String status = questionData['status'] ?? 'Pending';
              final String answer = questionData['answer'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  leading: Icon(
                    status == 'Answered' ? Icons.check_circle : Icons.help_outline,
                    color: status == 'Answered' ? Colors.green : Colors.orange,
                  ),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${'status'.tr()}: $status'),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Your Question:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          Text(questionData['description'] ?? ''),
                          const SizedBox(height: 10),
                          if (questionData['imageUrl'] != null)
                            Image.network(questionData['imageUrl']),
                          const Divider(height: 30),
                          Text("Expert's Answer:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                          const SizedBox(height: 4),
                          Text(answer.isNotEmpty ? answer : "Waiting for an expert to reply..."),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AskQuestionScreen(),
          ));
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        tooltip: 'ask_new_question'.tr(),
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}
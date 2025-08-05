// lib/screens/reply_to_question_screen.dart (CORRECTED)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// easy_localization import has been removed

class ReplyToQuestionScreen extends StatefulWidget {
  final DocumentSnapshot requestDoc;
  const ReplyToQuestionScreen({super.key, required this.requestDoc});

  @override
  State<ReplyToQuestionScreen> createState() => _ReplyToQuestionScreenState();
}

class _ReplyToQuestionScreenState extends State<ReplyToQuestionScreen> {
  // ... rest of the code is the same and correct
  final _replyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submitReply() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final expert = FirebaseAuth.instance.currentUser!;
      await widget.requestDoc.reference.update({
        'status': 'replied',
        'expertReply': _replyController.text,
        'expertId': expert.uid,
        'expertName': expert.displayName ?? 'Expert',
        'repliedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply sent successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reply: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.requestDoc.data() as Map<String, dynamic>;
    final imageUrl = data['imageUrl'];
    final description = data['description'];
    final userName = data['userName'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reply to Question'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question from: $userName', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            const Divider(height: 32),
            Text('Your Reply', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _replyController,
                decoration: const InputDecoration(
                  labelText: 'Write your expert advice here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 6,
                validator: (value) => value!.isEmpty ? 'Reply cannot be empty' : null,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitReply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Send Reply'),
            )
          ],
        ),
      ),
    );
  }
}
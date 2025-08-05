// lib/screens/edit_expert_profile_screen.dart (NEW FILE)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditExpertProfileScreen extends StatefulWidget {
  const EditExpertProfileScreen({super.key});

  @override
  State<EditExpertProfileScreen> createState() => _EditExpertProfileScreenState();
}

class _EditExpertProfileScreenState extends State<EditExpertProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _specialtyController = TextEditingController();
  final _feeController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExpertData();
  }
  
  // Load existing data to pre-fill the form
  Future<void> _loadExpertData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      _specialtyController.text = data['specialty'] ?? '';
      _feeController.text = data['consultationFee'] ?? '';
      _contactController.text = data['publicContact'] ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'specialty': _specialtyController.text,
        'consultationFee': _feeController.text,
        'publicContact': _contactController.text,
      }, SetOptions(merge: true)); // merge:true adds fields without overwriting the whole doc

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expert Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _specialtyController, decoration: const InputDecoration(labelText: 'Your Specialty (e.g., Pest Control)')),
              TextFormField(controller: _feeController, decoration: const InputDecoration(labelText: 'Consultation Fee (e.g., 200 per call)')),
              TextFormField(controller: _contactController, decoration: const InputDecoration(labelText: 'Public Contact Number'), keyboardType: TextInputType.phone),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Save Profile'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
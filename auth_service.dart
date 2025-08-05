// lib/services/auth_service.dart (CORRECTED)

import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _saveUserData(User user, String role) async {
    await _db.collection('users').doc(user.uid).set({
      'role': role,
      'email': user.email,
      'name': user.displayName,
      'uid': user.uid,
    }, SetOptions(merge: true));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_name', user.displayName ?? 'Farmer');
    await prefs.setString('user_role', role);
  }

  Future<User?> registerWithEmail(String name, String email, String password, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await _saveUserData(user, role);
      }
      return user;
    } catch (e) {
      debugPrint(e.toString()); // --- FIX IS HERE ---
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
        final role = (doc.data() as Map<String, dynamic>)['role'] ?? 'farmer';
        await _saveUserData(user, role);
      }
      return user;
    } catch (e) {
      debugPrint(e.toString()); // --- FIX IS HERE ---
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        await _saveUserData(user, 'farmer');
      }
      return user;
    } catch (e) {
      debugPrint(e.toString()); // --- FIX IS HERE ---
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
// ==================== CONTROLLER ====================
// lib/controllers/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:preloved_mobile_app/model/userModel.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toJson());

      // Update display name
      await userCredential.user!.updateDisplayName(name);

      return {
        'success': true,
        'message': 'Registration successful!',
        'user': user,
      };
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'email-already-in-use':
          message = 'Email is already registered.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        default:
          message = 'Registration failed: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
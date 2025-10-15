

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register with student ID and phone as password
  Future<User?> registerWithStudentId(
    String studentId, 
    String phoneNumber, 
    String fullName,
  ) async {
    try {
      // Create email from student ID
      String email = '$studentId@must.ac.mw';
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: phoneNumber, // Using phone number as password
      );

      // Add user to Firestore with student ID and phone
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'studentId': studentId,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'createdAt': DateTime.now(),
      });

      return userCredential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Login with student ID and phone as password
  Future<User?> loginWithStudentId(String studentId, String phoneNumber) async {
    try {
      String email = '$studentId@must.ac.mw';
      
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: phoneNumber,
      );
      return userCredential.user;
      
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;
}
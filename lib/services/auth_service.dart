import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User?> signInAnonymously() async {
    // Let exceptions propagate so the caller (provider) can surface them
    // to the UI via AsyncValue.error instead of silently returning null.
    final userCredential = await _firebaseAuth.signInAnonymously();
    debugPrint("Anonymous sign-in succeeded: ${userCredential.user?.uid}");
    return userCredential.user;
  }
}

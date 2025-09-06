import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// Provides the AuthService instance
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// The new provider that handles the entire app initialization
final initializationProvider = FutureProvider<User?>((ref) async {
  final authService = ref.read(authServiceProvider);
  // If there's no current user, sign one in anonymously
  if (authService.currentUser == null) {
    return await authService.signInAnonymously();
  }
  // Otherwise, return the existing user
  return authService.currentUser;
});
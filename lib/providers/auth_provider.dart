import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// Provides the AuthService instance
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Handles app initialization / anonymous sign-in.
// Errors now propagate naturally into the .error branch of .when,
// instead of being swallowed into a null data value.
final initializationProvider = FutureProvider<User?>((ref) async {
  final authService = ref.read(authServiceProvider);
  if (authService.currentUser == null) {
    return await authService.signInAnonymously();
  }
  return authService.currentUser;
});

// Retry helper: UI calls this to re-run the initialization flow.
// Equivalent to `ref.invalidate(initializationProvider)` — exposed as a
// named function for clarity at call sites.
void retryInitialization(WidgetRef ref) {
  ref.invalidate(initializationProvider);
}

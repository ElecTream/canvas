import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central gate for the Phase-6 runtime sunset of Firebase. Once set, the
/// SharedPreferences flag guarantees [main] never calls `Firebase.initializeApp`
/// again on this install. The Firebase packages stay in the binary solely
/// so [FirestoreImporter] can run the one-shot legacy pull; after it calls
/// [markMigrationComplete], Firebase is unreachable at runtime.
class LegacyFirebaseGate {
  static const migrationCompletePrefKey = 'canvas.firestore_migration_complete';

  /// True if Firebase was initialised during this process (i.e. migration
  /// is still pending). Cheap to call many times.
  static bool get isFirebaseActive => Firebase.apps.isNotEmpty;

  /// Persist the "don't init Firebase again" flag AND tear down the running
  /// Firebase app so the rest of this process doesn't hold a live handle.
  static Future<void> markMigrationComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(migrationCompletePrefKey, true);
    try {
      for (final app in List.of(Firebase.apps)) {
        await app.delete();
      }
    } catch (e) {
      // Delete is best-effort; the prefs flag alone is sufficient to prevent
      // future boots from re-initialising.
      debugPrint('LegacyFirebaseGate: Firebase.app.delete() failed: $e');
    }
  }
}

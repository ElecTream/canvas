import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/notes_dao.dart';
import 'auth_service.dart';
import 'firestore_importer.dart';

/// Universal boot-time migrator. Runs on every app launch; each step is
/// idempotent and gated on drift flags so it's safe regardless of which
/// prior phase the user shipped on:
///
///   * fresh install — steps 1–2 no-op, step 3 gated on sign-in.
///   * v0.5.1 Firestore-anon user — full path.
///   * upgraded-from-Phase-1 user (drift populated, no Google) — step 1 no-op,
///     step 3 runs on first sign-in.
///   * already-migrated user — everything short-circuits.
///
/// Returns a [MigrationReport] so the caller can log / surface. Never throws
/// — errors are captured so one bad step doesn't keep the user out of the
/// app.
class LaunchMigrator {
  LaunchMigrator({
    required NotesDao dao,
    required AuthService auth,
  })  : _dao = dao,
        _auth = auth;

  final NotesDao _dao;
  final AuthService _auth;

  Future<MigrationReport> run() async {
    final report = MigrationReport();
    await _dao.ensureState();

    // --- Step 1: legacy Firestore pull + backup -----------------------------
    if (!await _dao.hasImportedFromFirestore()) {
      try {
        await _auth.ensureLegacyFirebaseUser();
        final imp = await FirestoreImporter(_dao).importIfNeeded();
        report.importedFromFirestore = imp.seeded;
        if (imp.error != null) report.errors.add(imp.error!);
      } catch (e) {
        debugPrint('LaunchMigrator: firestore pull failed: $e');
        report.errors.add(e);
      }
    }

    // --- Step 2: restore Google session ------------------------------------
    try {
      final user = await _auth.signInSilently();
      report.googleSessionRestored = user != null;
    } catch (e) {
      debugPrint('LaunchMigrator: silent sign-in failed: $e');
      report.errors.add(e);
    }

    // --- Step 3+ live in SyncService ---------------------------------------
    // First Drive push + folder creation happens inside [SyncService.syncNow]
    // gated on `hasFirstDrivePushComplete`. The pull-on-open triggered from
    // initializationProvider will drive it when the user is signed in.

    return report;
  }
}

class MigrationReport {
  int importedFromFirestore = 0;
  bool googleSessionRestored = false;
  final List<Object> errors = [];

  @override
  String toString() =>
      'MigrationReport(importedFromFirestore: $importedFromFirestore, '
      'googleSessionRestored: $googleSessionRestored, '
      'errors: ${errors.length})';
}

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/notes_dao.dart';
import '../models/note.dart';
import 'legacy_firebase_gate.dart';

/// One-shot pull of legacy Firestore notes into drift. Idempotent — guarded
/// by the `imported_from_firestore` flag in the sync_state row.
///
/// Writes a full JSON backup of the Firestore payload to the app documents
/// directory before touching drift, so even a crashed import leaves a
/// user-recoverable file. Called from [LaunchMigrator] in Phase 5.
class FirestoreImporter {
  FirestoreImporter(this._dao);

  final NotesDao _dao;

  Future<ImportReport> importIfNeeded() async {
    if (await _dao.hasImportedFromFirestore()) {
      // Drift says we're done. Make sure the prefs flag + Firebase teardown
      // also reflect that (catches the rare case where a prior run marked
      // drift complete but crashed before flipping prefs).
      await LegacyFirebaseGate.markMigrationComplete();
      return const ImportReport(seeded: 0, alreadyDone: true);
    }
    // Main gated Firebase.initializeApp on the prefs flag; if Firebase isn't
    // active here we must never have needed it. Mark drift complete too so
    // LaunchMigrator stops asking on every launch.
    if (!LegacyFirebaseGate.isFirebaseActive) {
      await _dao.markImportedFromFirestore();
      return const ImportReport(seeded: 0, alreadyDone: false);
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const ImportReport(seeded: 0, alreadyDone: false);
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notes')
          .get();

      if (snap.docs.isEmpty) {
        await _dao.markImportedFromFirestore();
        await LegacyFirebaseGate.markMigrationComplete();
        return const ImportReport(seeded: 0, alreadyDone: false);
      }

      final backupPath = await _writeBackup(uid, snap.docs);
      await _dao.recordLegacyBackup(backupPath);

      // Single pre-fetch of existing ids; avoids O(N²) re-scan per note on
      // large collections (1000 notes → 1M row materialisations otherwise).
      final existingIds =
          (await _dao.getAllNotes()).map((n) => n.id).toSet();

      var imported = 0;
      for (final doc in snap.docs) {
        final note = Note.fromJson(doc.data());
        if (existingIds.contains(note.id)) continue;
        // markDirty: true — these notes aren't on Drive yet, so they need to
        // be included in the first Drive push.
        await _dao.upsertNote(note, markDirty: true);
        existingIds.add(note.id);
        imported++;
      }
      await _dao.markImportedFromFirestore();
      await LegacyFirebaseGate.markMigrationComplete();
      debugPrint(
          'FirestoreImporter: seeded $imported notes, backup at $backupPath');
      return ImportReport(seeded: imported, alreadyDone: false);
    } catch (e) {
      debugPrint('FirestoreImporter failed: $e — will retry next launch');
      return ImportReport.error(e);
    }
  }

  Future<String> _writeBackup(
      String uid, List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final path = p.join(dir.path, 'canvas-backup-pre-migration-$ts.json');
    final payload = jsonEncode({
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'source': 'firestore',
      'anonUid': uid,
      'schemaNote':
          'createdAt/updatedAt fields were Firestore Timestamps; rewritten to ISO-8601',
      'notes': docs.map((d) => _sanitize(d.data())).toList(),
    });
    final f = File(path);
    await f.writeAsString(payload, flush: true);
    return path;
  }

  Map<String, dynamic> _sanitize(Map<String, dynamic> m) {
    final out = <String, dynamic>{};
    for (final e in m.entries) {
      final v = e.value;
      if (v is Timestamp) {
        out[e.key] = v.toDate().toUtc().toIso8601String();
      } else {
        out[e.key] = v;
      }
    }
    return out;
  }
}

class ImportReport {
  final int seeded;
  final bool alreadyDone;
  final Object? error;
  const ImportReport({
    required this.seeded,
    required this.alreadyDone,
    this.error,
  });

  factory ImportReport.error(Object e) =>
      ImportReport(seeded: 0, alreadyDone: false, error: e);
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:local_sync/local_sync.dart' as ls;

import '../data/images_dao.dart';
import '../data/notes_dao.dart';
import '../services/auth_service.dart';
import '../services/image_service.dart';
import 'blob_syncer.dart';
import 'drive_adapter.dart';
import 'drift_note_store.dart';
import 'note_sync_record.dart';

enum SyncPhase { idle, running }

class SyncStatus {
  final SyncPhase phase;
  final DateTime? lastSyncAt;
  final ls.SyncReport? lastReport;
  final BlobSyncReport? lastBlobReport;
  final int lastOrphansDeleted;
  final Object? lastError;

  const SyncStatus({
    required this.phase,
    this.lastSyncAt,
    this.lastReport,
    this.lastBlobReport,
    this.lastOrphansDeleted = 0,
    this.lastError,
  });

  SyncStatus copyWith({
    SyncPhase? phase,
    DateTime? lastSyncAt,
    ls.SyncReport? lastReport,
    BlobSyncReport? lastBlobReport,
    int? lastOrphansDeleted,
    Object? lastError,
  }) =>
      SyncStatus(
        phase: phase ?? this.phase,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        lastReport: lastReport ?? this.lastReport,
        lastBlobReport: lastBlobReport ?? this.lastBlobReport,
        lastOrphansDeleted: lastOrphansDeleted ?? this.lastOrphansDeleted,
        lastError: lastError ?? this.lastError,
      );

  static const initial = SyncStatus(phase: SyncPhase.idle);
}

/// Wires auth → DriveAdapter → SyncEngine + blob sync. One instance per app.
class SyncService {
  SyncService({
    required this.auth,
    required this.store,
    required this.dao,
    required this.imagesDao,
    required this.imageService,
  }) : _adapter = DriveAdapter(
          appFolderName: 'canvas',
          authClientProvider: auth.authenticatedHttpClient,
        ) {
    _blobSyncer = BlobSyncer(
      imagesDao: imagesDao,
      notesDao: dao,
      imageService: imageService,
      adapter: _adapter,
    );
  }

  final AuthService auth;
  final DriftNoteStore store;
  final NotesDao dao;
  final ImagesDao imagesDao;
  final ImageService imageService;
  final DriveAdapter _adapter;
  late final BlobSyncer _blobSyncer;

  final _statusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _status = SyncStatus.initial;
  SyncStatus get status => _status;
  Stream<SyncStatus> get statusStream => _statusController.stream;

  void _emit(SyncStatus s) {
    _status = s;
    _statusController.add(s);
  }

  Future<ls.SyncReport> syncNow() async {
    if (auth.currentUser == null) {
      final err = StateError('Sign in to sync.');
      _emit(_status.copyWith(lastError: err));
      throw err;
    }
    _emit(_status.copyWith(phase: SyncPhase.running, lastError: null));

    try {
      final firstPush = !await dao.hasFirstDrivePushComplete();

      // Authenticate the Drive adapter once so both blob + record passes reuse
      // the same folder ids.
      await _adapter.authenticate();

      // First-push alignment: before marking everything dirty + running the
      // engine, seed `remoteRev` for any local id that already has a matching
      // remote file. Without this, the engine reads (dirty local, null rev,
      // remote exists) as a conflict for every note, and the conflict state
      // persists across syncs because push is skipped for conflicted ids.
      if (firstPush) {
        final aligned = await _alignRemoteRevsFromIndex();
        debugPrint('syncNow: aligned $aligned remoteRev(s) for firstPush');
        await dao.markAllActiveDirty();
      }

      // Blob push before record push: ensures remote notes that reference
      // these blobs already have them available on pull elsewhere.
      final blobPushReport = await _blobSyncer.pushMissing();

      final engine = ls.SyncEngine<NoteSyncRecord>(
        local: store,
        remote: _NoAuthWrapper(_adapter),
      );
      final report = await engine.syncNow();

      // Blob pull after record pull: notes now reference any new attachment
      // filenames + their SHAs have been stashed in `image_blobs`.
      final blobPullReport = await _blobSyncer.pullMissing();
      final blobMerged = BlobSyncReport()
        ..pushed = blobPushReport.pushed
        ..pulled = blobPullReport.pulled
        ..skippedMissingLocal = blobPushReport.skippedMissingLocal
        ..skippedMissingSha = blobPullReport.skippedMissingSha
        ..errors = blobPushReport.errors + blobPullReport.errors;

      // Reconcile remote orphans every sync. Cost is a set-diff against the
      // already-fetched index plus N deletes proportional to actual orphans
      // (zero when clean), so it's cheap when there's nothing to do. Earlier
      // daily throttle meant stragglers lingered for up to 24h; users
      // noticed the drift and asked for it gone.
      final orphansDeleted = (report.error == null)
          ? await _reconcileRemoteOrphans()
          : 0;
      if (report.error == null) {
        await dao.setLastOrphanScanAt(DateTime.now().toUtc());
      }

      if (firstPush && report.error == null) {
        await dao.markFirstDrivePushComplete();
      }
      _emit(SyncStatus(
        phase: SyncPhase.idle,
        lastSyncAt: DateTime.now().toUtc(),
        lastReport: report,
        lastBlobReport: blobMerged,
        lastOrphansDeleted: orphansDeleted,
        lastError: report.error,
      ));
      if (report.error != null) {
        debugPrint('Sync finished with error: ${report.error}');
      }
      return report;
    } catch (e) {
      _emit(_status.copyWith(phase: SyncPhase.idle, lastError: e));
      rethrow;
    }
  }

  /// Seeds `remoteRev` on local records that have a corresponding remote
  /// file but no known rev yet. Returns the number of rows aligned.
  Future<int> _alignRemoteRevsFromIndex() async {
    final index = await _adapter.listRemote();
    final locals = await dao.getAllNotes();
    int aligned = 0;
    for (final n in locals) {
      final remoteRev = index.active[n.id];
      if (remoteRev == null) continue;
      final have = await dao.getRemoteRev(n.id);
      if (have != null) continue;
      await dao.setRemoteRev(n.id, remoteRev);
      aligned++;
    }
    return aligned;
  }

  /// Fire-and-forget sync. Errors are logged into [SyncStatus] but never
  /// thrown, so boot paths (pull-on-open) can just call this and move on.
  Future<void> backgroundSync() async {
    try {
      await syncNow();
    } catch (e) {
      debugPrint('background sync failed: $e');
    }
  }

  /// One-shot Drive usage fetch. Authenticates if needed. Throws if not
  /// signed in; callers should gate on [AuthService.currentUser].
  Future<ls.UsageInfo> fetchUsage() async {
    await _adapter.authenticate();
    return _adapter.usage();
  }

  /// Walk remote `/canvas/notes/`, delete any file whose id isn't present
  /// locally as an active record or a retained tombstone. Returns count of
  /// deletions. Uses the adapter's cached index when available (populated
  /// by the engine's [listRemote] call earlier in [syncNow]); falls back to
  /// a fresh list if no cache exists.
  ///
  /// Historical note: we previously also skipped ids that appeared in
  /// `index.tombstoned`. That masked a real bug — a crashed [pushTombstone]
  /// can leave the `/notes/<id>.json` AND `/tombstones/<id>.json` files
  /// co-existing, and the old skip meant reconcile would never delete that
  /// orphan active file. The rule now: if local doesn't know about the id,
  /// the remote active file is an orphan regardless of tombstone state.
  Future<int> _reconcileRemoteOrphans() async {
    final index = _adapter.lastIndex ?? await _adapter.listRemote();
    final localIds = (await dao.getAllNotes()).map((n) => n.id).toSet();

    // Intentionally *not* skipping ids present in local tombstones. A local
    // tombstone + remote active file means the pushTombstone flow never got
    // to delete /notes/<id>.json (interrupted sync, stale migration, etc).
    // Deleting the orphan here is safe: next sync's pushTombstone will see
    // the file is already gone and move on, still writing the tombstone file
    // so other devices pick up the delete.
    int deleted = 0;
    int failed = 0;
    for (final id in List.of(index.active.keys)) {
      if (localIds.contains(id)) continue;
      try {
        final ok = await _adapter.deleteRemoteNoteFile(id);
        if (ok) deleted++;
      } catch (e) {
        failed++;
        debugPrint('orphan delete failed for $id: $e');
      }
    }
    if (failed > 0) {
      debugPrint('orphan reconcile: $failed failure(s); will retry next scan');
    }
    return deleted;
  }

  /// Dry-run variant used by the "Scan Drive" UI. Returns the orphaned +
  /// locally-only id sets without touching remote.
  Future<OrphanReport> dryRunOrphans() async {
    if (auth.currentUser == null) {
      throw StateError('Sign in to scan.');
    }
    await _adapter.authenticate();
    final index = await _adapter.listRemote();
    final localIds = (await dao.getAllNotes()).map((n) => n.id).toSet();

    // Same rule as [_reconcileRemoteOrphans]: any id in remote /notes/ that
    // has no active local record is an orphan, regardless of local tombstone
    // state — we want the Purge button's count to match what reconcile will
    // actually clean.
    final orphans = <String>[];
    for (final id in index.active.keys) {
      if (localIds.contains(id)) continue;
      orphans.add(id);
    }
    final localOnly = <String>[];
    for (final id in localIds) {
      if (!index.active.containsKey(id)) localOnly.add(id);
    }
    return OrphanReport(
      remoteCount: index.active.length,
      localCount: localIds.length,
      orphans: orphans,
      localOnly: localOnly,
    );
  }

  /// Run orphan cleanup now. Used by the "Purge" action on the usage card and
  /// the "Clean up" action on the Scan Drive dialog. Always re-scans Drive
  /// directly — no reliance on a cached index — so the count matches current
  /// state, not whatever was last seen in UI.
  Future<int> cleanupOrphansNow() async {
    final r = await cleanupOrphansNowVerbose();
    return r.deleted;
  }

  /// Verbose variant of [cleanupOrphansNow] that returns the full scan /
  /// delete / failure counts. UI uses this to reveal what the adapter
  /// actually saw (helps debug mismatches between the usage card's cached
  /// `recordCount` and the live state of Drive).
  Future<({
    int scanned,
    int uniqueUuids,
    int orphanUuids,
    int dupes,
    int deleted,
    int failed,
    int local,
  })> cleanupOrphansNowVerbose() async {
    if (auth.currentUser == null) {
      throw StateError('Sign in to clean up.');
    }
    await _adapter.authenticate();
    final localIds = (await dao.getAllNotes()).map((n) => n.id).toSet();
    final r = await _adapter.purgeOrphansDirect(localIds);
    debugPrint('purge: scanned=${r.scanned} unique=${r.uniqueUuids} '
        'orphans=${r.orphanUuids} dupes=${r.dupes} deleted=${r.deleted} '
        'failed=${r.failed} local=${localIds.length}');
    await dao.setLastOrphanScanAt(DateTime.now().toUtc());
    return (
      scanned: r.scanned,
      uniqueUuids: r.uniqueUuids,
      orphanUuids: r.orphanUuids,
      dupes: r.dupes,
      deleted: r.deleted,
      failed: r.failed,
      local: localIds.length,
    );
  }

  void dispose() {
    _adapter.close();
    _statusController.close();
  }
}

class OrphanReport {
  final int remoteCount;
  final int localCount;
  final List<String> orphans;
  final List<String> localOnly;

  const OrphanReport({
    required this.remoteCount,
    required this.localCount,
    required this.orphans,
    required this.localOnly,
  });
}

/// Adapter wrapper that skips re-authenticating — we already called
/// `authenticate()` on the real adapter up front so we can run a blob
/// pass before the engine touches records.
class _NoAuthWrapper implements ls.SyncAdapter<NoteSyncRecord> {
  _NoAuthWrapper(this._inner);
  final DriveAdapter _inner;

  @override
  Future<void> authenticate() async {/* already authed */}

  @override
  Future<ls.RemoteIndex> listRemote() => _inner.listRemote();
  @override
  Future<NoteSyncRecord> fetch(String id) => _inner.fetch(id);
  @override
  Future<DateTime> push(NoteSyncRecord record) => _inner.push(record);
  @override
  Future<void> pushTombstone(String id, DateTime deletedAt) =>
      _inner.pushTombstone(id, deletedAt);
  @override
  Future<void> writeConflictCopy(
          String id, String iso, Map<String, dynamic> remoteJson) =>
      _inner.writeConflictCopy(id, iso, remoteJson);
  @override
  Future<Uint8List> fetchBlob(String blobId) => _inner.fetchBlob(blobId);
  @override
  Future<String> pushBlob(Uint8List bytes, String name) =>
      _inner.pushBlob(bytes, name);
  @override
  Future<void> deleteBlob(String blobId) => _inner.deleteBlob(blobId);
  @override
  Future<ls.UsageInfo> usage() => _inner.usage();
  @override
  NoteSyncRecord fromJson(Map<String, dynamic> json) => _inner.fromJson(json);
}

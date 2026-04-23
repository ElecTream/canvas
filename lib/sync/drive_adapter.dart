import 'dart:convert';
import 'dart:typed_data';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:local_sync/local_sync.dart' as ls;

import 'note_sync_record.dart';

/// Drive-backed [ls.SyncAdapter].
///
/// Folder layout (inside the `drive.file`-scoped sandbox):
/// ```
/// canvas/
///   notes/<uuid>.json
///   blobs/<sha256>.<ext>      (unused in Phase 3a; wired in Phase 3b)
///   conflicts/<id>.conflict-<iso>.json
///   tombstones/<id>.json      ({"deletedAt": "<iso>"})
/// ```
///
/// [authClientProvider] returns a fresh authenticated client each sync so
/// token refresh happens at the auth layer, not here.
class DriveAdapter implements ls.SyncAdapter<NoteSyncRecord> {
  DriveAdapter({
    required this.appFolderName,
    required this.authClientProvider,
  });

  final String appFolderName;
  final Future<http.Client> Function() authClientProvider;

  static const _mimeFolder = 'application/vnd.google-apps.folder';
  static const _mimeJson = 'application/json';

  http.Client? _client;
  drive.DriveApi? _api;
  String? _rootFolderId;
  String? _notesFolderId;
  String? _blobsFolderId;
  String? _conflictsFolderId;
  String? _tombstonesFolderId;

  /// Last result of [listRemote]. Mutated on every listRemote call. Callers
  /// (sync_service) can reuse it to skip a second remote scan during orphan
  /// reconciliation, and push() can consult it to skip the
  /// `_removeTombstoneFile` round trip when the id isn't tombstoned.
  ls.RemoteIndex? lastIndex;

  /// Wall-clock age of [lastIndex]; used to decide whether a cached value is
  /// fresh enough for the caller.
  DateTime? lastIndexAt;

  @override
  Future<void> authenticate() async {
    _client?.close();
    _client = await authClientProvider();
    _api = drive.DriveApi(_client!);
    _rootFolderId = await _ensureFolder(appFolderName, parentId: null);
    // Subfolders are independent; issue them in parallel.
    final results = await Future.wait([
      _ensureFolder('notes', parentId: _rootFolderId),
      _ensureFolder('blobs', parentId: _rootFolderId),
      _ensureFolder('conflicts', parentId: _rootFolderId),
      _ensureFolder('tombstones', parentId: _rootFolderId),
    ]);
    _notesFolderId = results[0];
    _blobsFolderId = results[1];
    _conflictsFolderId = results[2];
    _tombstonesFolderId = results[3];
  }

  /// Drift stores DateTime at epoch-second precision, but Drive's
  /// `modifiedTime` is milliseconds. Truncating at the adapter boundary keeps
  /// both sides identical after a round-trip so the engine's `isAfter` check
  /// doesn't fire on ghost sub-second differences (every sync reporting
  /// "remote changed" when nothing actually did).
  DateTime _toSec(DateTime t) {
    final ms = t.toUtc().millisecondsSinceEpoch;
    return DateTime.fromMillisecondsSinceEpoch((ms ~/ 1000) * 1000,
        isUtc: true);
  }

  Future<String> _ensureFolder(String name, {required String? parentId}) async {
    final parentClause =
        parentId == null ? "'root' in parents" : "'$parentId' in parents";
    final q =
        "mimeType = '$_mimeFolder' and name = '$name' and $parentClause and trashed = false";
    final list = await _api!.files.list(q: q, spaces: 'drive', $fields: 'files(id)');
    final existing = list.files;
    if (existing != null && existing.isNotEmpty) return existing.first.id!;
    final created = await _api!.files.create(drive.File()
      ..name = name
      ..mimeType = _mimeFolder
      ..parents = [if (parentId != null) parentId]);
    return created.id!;
  }

  Future<drive.File?> _findByName(String name, {required String parentId}) async {
    final q =
        "name = '${_escape(name)}' and '$parentId' in parents and trashed = false";
    final list = await _api!.files.list(
        q: q, spaces: 'drive', $fields: 'files(id,name,modifiedTime,size)');
    final files = list.files;
    if (files == null || files.isEmpty) return null;
    return files.first;
  }

  String _escape(String s) => s.replaceAll("'", r"\'");

  @override
  Future<ls.RemoteIndex> listRemote() async {
    _ensureAuth();
    final active = <String, DateTime>{};
    final tombstoned = <String, DateTime>{};

    // Active notes: list everything in /notes/.
    String? pageToken;
    do {
      final res = await _api!.files.list(
        q: "'$_notesFolderId' in parents and trashed = false",
        spaces: 'drive',
        $fields: 'nextPageToken, files(id,name,modifiedTime)',
        pageToken: pageToken,
      );
      for (final f in res.files ?? const <drive.File>[]) {
        final n = f.name;
        if (n == null || !n.endsWith('.json')) continue;
        final id = n.substring(0, n.length - '.json'.length);
        final m = f.modifiedTime;
        if (m != null) active[id] = _toSec(m);
      }
      pageToken = res.nextPageToken;
    } while (pageToken != null);

    // Tombstones: list /tombstones/, read each to get deletedAt.
    pageToken = null;
    do {
      final res = await _api!.files.list(
        q: "'$_tombstonesFolderId' in parents and trashed = false",
        spaces: 'drive',
        $fields: 'nextPageToken, files(id,name,modifiedTime)',
        pageToken: pageToken,
      );
      for (final f in res.files ?? const <drive.File>[]) {
        final n = f.name;
        if (n == null || !n.endsWith('.json')) continue;
        final id = n.substring(0, n.length - '.json'.length);
        // Read tombstone content to get exact deletedAt.
        try {
          final media = await _api!.files.get(f.id!,
              downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
          final text = await _readMedia(media);
          final map = jsonDecode(text) as Map<String, dynamic>;
          final d = map['deletedAt'];
          final deletedAt = d is String
              ? DateTime.parse(d).toUtc()
              : (f.modifiedTime?.toUtc() ?? DateTime.now().toUtc());
          tombstoned[id] = _toSec(deletedAt);
        } catch (_) {
          // Fall back to file modifiedTime if body is unreadable.
          tombstoned[id] =
              _toSec(f.modifiedTime?.toUtc() ?? DateTime.now().toUtc());
        }
      }
      pageToken = res.nextPageToken;
    } while (pageToken != null);

    final index = ls.RemoteIndex(active: active, tombstoned: tombstoned);
    lastIndex = index;
    lastIndexAt = DateTime.now().toUtc();
    return index;
  }

  Future<String> _readMedia(drive.Media media) async {
    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }
    return utf8.decode(bytes);
  }

  Future<Uint8List> _readMediaBytes(drive.Media media) async {
    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }
    return Uint8List.fromList(bytes);
  }

  @override
  Future<NoteSyncRecord> fetch(String id) async {
    _ensureAuth();
    final file = await _findByName('$id.json', parentId: _notesFolderId!);
    if (file == null) {
      throw StateError('Remote note $id not found');
    }
    final media = await _api!.files.get(file.id!,
        downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    final text = await _readMedia(media);
    final json = jsonDecode(text) as Map<String, dynamic>;
    return NoteSyncRecord.fromJson(json);
  }

  @override
  Future<DateTime> push(NoteSyncRecord record) async {
    _ensureAuth();
    final name = '${record.id}.json';
    final bytes = utf8.encode(jsonEncode(record.toJson()));
    final media = drive.Media(Stream.value(bytes), bytes.length,
        contentType: _mimeJson);
    final existing = await _findByName(name, parentId: _notesFolderId!);
    drive.File written;
    if (existing == null) {
      final meta = drive.File()
        ..name = name
        ..mimeType = _mimeJson
        ..parents = [_notesFolderId!];
      written = await _api!.files.create(meta,
          uploadMedia: media, $fields: 'id,modifiedTime');
    } else {
      written = await _api!.files.update(drive.File(), existing.id!,
          uploadMedia: media, $fields: 'id,modifiedTime');
    }
    // If this id had a tombstone remote-side, remove it — record is back.
    // Consult the cached index so we skip the list+delete round trip when
    // no tombstone exists (the common case).
    final maybeTomb = lastIndex?.tombstoned.containsKey(record.id);
    if (maybeTomb != false) {
      await _removeTombstoneFile(record.id);
      lastIndex?.tombstoned.remove(record.id);
    }

    final remoteRev = written.modifiedTime != null
        ? _toSec(written.modifiedTime!)
        : _toSec(record.updatedAt.toUtc());
    // Reflect the push in the cached index so subsequent reads line up.
    lastIndex?.active[record.id] = remoteRev;
    return remoteRev;
  }

  /// Delete the `notes/<id>.json` file on Drive (no tombstone). Used by
  /// reconciliation to drop remote orphans whose local record is gone and
  /// for whom no tombstone would ever be pushed.
  Future<bool> deleteRemoteNoteFile(String id) async {
    _ensureAuth();
    final existing = await _findByName('$id.json', parentId: _notesFolderId!);
    if (existing == null) return false;
    await _api!.files.delete(existing.id!);
    lastIndex?.active.remove(id);
    return true;
  }

  /// Delete everything on Drive's `/notes/` that shouldn't be there. Two
  /// classes of garbage get cleaned:
  ///
  /// 1. True orphans — a `<uuid>.json` whose uuid is *not* in [keepLocalIds].
  /// 2. Duplicates — multiple files with the same `<uuid>.json` name
  ///    (Drive allows this; `files.create` without a dedup query leaves two
  ///    separate entries). Keep the newest `modifiedTime`, delete the rest.
  ///
  /// The earlier flat "skip if uuid in local" rule missed case 2, which is
  /// the actual source of the usage-card vs purge mismatch: a user with
  /// 11 files / 8 unique uuids and 8 local rows sees "3 orphans on Drive"
  /// but the per-id reconcile path finds nothing to delete.
  Future<({
    int scanned,
    int uniqueUuids,
    int orphanUuids,
    int dupes,
    int deleted,
    int failed,
  })> purgeOrphansDirect(Set<String> keepLocalIds) async {
    _ensureAuth();
    int scanned = 0;
    final byUuid = <String, List<drive.File>>{};

    String? pageToken;
    do {
      final res = await _api!.files.list(
        q: "'$_notesFolderId' in parents and trashed = false",
        spaces: 'drive',
        $fields: 'nextPageToken, files(id,name,modifiedTime)',
        pageToken: pageToken,
      );
      for (final f in res.files ?? const <drive.File>[]) {
        scanned++;
        final name = f.name;
        final fileId = f.id;
        if (name == null || fileId == null || !name.endsWith('.json')) {
          continue;
        }
        final uuid = name.substring(0, name.length - '.json'.length);
        byUuid.putIfAbsent(uuid, () => []).add(f);
      }
      pageToken = res.nextPageToken;
    } while (pageToken != null);

    int orphanUuids = 0;
    int dupes = 0;
    int deleted = 0;
    int failed = 0;
    for (final entry in byUuid.entries) {
      final uuid = entry.key;
      final files = entry.value;
      final isLocal = keepLocalIds.contains(uuid);
      if (!isLocal) {
        orphanUuids++;
        for (final f in files) {
          try {
            await _api!.files.delete(f.id!);
            deleted++;
          } catch (_) {
            failed++;
          }
        }
        lastIndex?.active.remove(uuid);
      } else if (files.length > 1) {
        // Keep newest, delete older dupes.
        files.sort((a, b) {
          final am = a.modifiedTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bm = b.modifiedTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bm.compareTo(am);
        });
        for (int i = 1; i < files.length; i++) {
          dupes++;
          try {
            await _api!.files.delete(files[i].id!);
            deleted++;
          } catch (_) {
            failed++;
          }
        }
      }
    }
    return (
      scanned: scanned,
      uniqueUuids: byUuid.length,
      orphanUuids: orphanUuids,
      dupes: dupes,
      deleted: deleted,
      failed: failed,
    );
  }

  @override
  Future<void> pushTombstone(String id, DateTime deletedAt) async {
    _ensureAuth();
    final name = '$id.json';
    final payload = utf8.encode(jsonEncode({
      'id': id,
      'deletedAt': deletedAt.toUtc().toIso8601String(),
    }));
    final media = drive.Media(Stream.value(payload), payload.length,
        contentType: _mimeJson);
    final existing =
        await _findByName(name, parentId: _tombstonesFolderId!);
    if (existing == null) {
      final meta = drive.File()
        ..name = name
        ..mimeType = _mimeJson
        ..parents = [_tombstonesFolderId!];
      await _api!.files.create(meta, uploadMedia: media);
    } else {
      await _api!.files.update(drive.File(), existing.id!,
          uploadMedia: media);
    }
    // Also remove the active note file if present.
    final noteFile = await _findByName(name, parentId: _notesFolderId!);
    if (noteFile != null) {
      await _api!.files.delete(noteFile.id!);
    }
  }

  Future<void> _removeTombstoneFile(String id) async {
    final existing =
        await _findByName('$id.json', parentId: _tombstonesFolderId!);
    if (existing != null) {
      await _api!.files.delete(existing.id!);
    }
  }

  @override
  Future<void> writeConflictCopy(
      String id, String isoTimestamp, Map<String, dynamic> remoteJson) async {
    _ensureAuth();
    final name = '$id.conflict-$isoTimestamp.json';
    final bytes = utf8.encode(jsonEncode(remoteJson));
    final media = drive.Media(Stream.value(bytes), bytes.length,
        contentType: _mimeJson);
    final meta = drive.File()
      ..name = name
      ..mimeType = _mimeJson
      ..parents = [_conflictsFolderId!];
    await _api!.files.create(meta, uploadMedia: media);
  }

  @override
  Future<Uint8List> fetchBlob(String blobId) async {
    _ensureAuth();
    final file = await _findByName(blobId, parentId: _blobsFolderId!);
    if (file == null) throw StateError('blob $blobId not found');
    final media = await _api!.files.get(file.id!,
        downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    return _readMediaBytes(media);
  }

  @override
  Future<String> pushBlob(Uint8List bytes, String name) async {
    _ensureAuth();
    final media = drive.Media(Stream.value(bytes), bytes.length);
    final existing = await _findByName(name, parentId: _blobsFolderId!);
    if (existing == null) {
      final meta = drive.File()
        ..name = name
        ..parents = [_blobsFolderId!];
      await _api!.files.create(meta, uploadMedia: media);
    }
    // If existing, skip re-upload. Blobs are content-addressed so same name
    // means same content.
    return name;
  }

  @override
  Future<void> deleteBlob(String blobId) async {
    _ensureAuth();
    final existing = await _findByName(blobId, parentId: _blobsFolderId!);
    if (existing != null) {
      await _api!.files.delete(existing.id!);
    }
  }

  @override
  Future<ls.UsageInfo> usage() async {
    _ensureAuth();
    int bytes = 0;
    int records = 0;
    int blobs = 0;
    for (final folderId in [
      _notesFolderId!,
      _blobsFolderId!,
      _conflictsFolderId!,
      _tombstonesFolderId!,
    ]) {
      String? pageToken;
      do {
        final res = await _api!.files.list(
          q: "'$folderId' in parents and trashed = false",
          spaces: 'drive',
          $fields: 'nextPageToken, files(id,size)',
          pageToken: pageToken,
        );
        for (final f in res.files ?? const <drive.File>[]) {
          final s = f.size;
          if (s != null) bytes += int.tryParse(s) ?? 0;
          if (folderId == _blobsFolderId) {
            blobs++;
          } else if (folderId == _notesFolderId) {
            records++;
          }
        }
        pageToken = res.nextPageToken;
      } while (pageToken != null);
    }
    return ls.UsageInfo(bytes: bytes, recordCount: records, blobCount: blobs);
  }

  @override
  NoteSyncRecord fromJson(Map<String, dynamic> json) =>
      NoteSyncRecord.fromJson(json);

  void _ensureAuth() {
    if (_api == null || _rootFolderId == null) {
      throw StateError('DriveAdapter not initialised; call authenticate() first.');
    }
  }

  void close() {
    _client?.close();
    _client = null;
    _api = null;
  }
}

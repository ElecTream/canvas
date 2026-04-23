import 'package:local_sync/local_sync.dart' as ls;

import '../data/images_dao.dart';
import '../data/notes_dao.dart';
import 'note_sync_record.dart';

/// Bridges the generic [ls.LocalStore] contract to the Canvas `NotesDao`.
/// Also relays attachment-filename → sha256 mappings between the note
/// records (which carry them through JSON round-trip) and the
/// `image_blobs` table (which is the source of truth for local blob state).
class DriftNoteStore implements ls.LocalStore<NoteSyncRecord> {
  DriftNoteStore(this._dao, this._imagesDao);
  final NotesDao _dao;
  final ImagesDao _imagesDao;

  @override
  Future<List<NoteSyncRecord>> getAllActive() async =>
      (await _dao.getAllNotes()).map(NoteSyncRecord.new).toList();

  @override
  Future<NoteSyncRecord?> getById(String id) async {
    final note = await _dao.getNoteById(id);
    return note == null ? null : NoteSyncRecord(note);
  }

  @override
  Future<void> upsert(NoteSyncRecord record,
      {required bool markDirty}) async {
    await _dao.upsertNote(record.note,
        markDirty: markDirty, remoteRev: record.updatedAt);
    // Remember remote-declared SHA mappings so the blob puller knows where
    // to fetch missing files from. Only write rows that don't already exist
    // locally — an existing local row reflects the user's actual file bytes
    // and must win.
    for (final e in record.attachmentShas.entries) {
      final existing = await _imagesDao.getByFilename(e.key);
      if (existing == null) {
        await _imagesDao.record(
          filename: e.key,
          sha256: e.value,
          // Unknown until blob fetch completes; 0 is a safe placeholder.
          sizeBytes: 0,
        );
      }
    }
  }

  @override
  Future<List<NoteSyncRecord>> getDirty() async {
    final notes = await _dao.getDirtyNotes();
    final out = <NoteSyncRecord>[];
    for (final n in notes) {
      final shas = await _imagesDao.shasFor(n.attachments);
      out.add(NoteSyncRecord(n, attachmentShas: shas));
    }
    return out;
  }

  @override
  Future<void> clearDirty(String id, {required DateTime remoteUpdatedAt}) =>
      _dao.clearDirty(id, remoteUpdatedAt);

  @override
  Future<DateTime?> getRemoteRev(String id) => _dao.getRemoteRev(id);

  @override
  Future<void> hardDelete(String id) => _dao.hardDeleteNote(id);

  @override
  Future<List<ls.Tombstone>> getTombstones(
      {required Duration retention}) async {
    final rows = await _dao.getTombstonesWithin(retention);
    return rows
        .map((r) => ls.Tombstone(id: r.id, deletedAt: r.deletedAt))
        .toList();
  }

  @override
  Future<void> addTombstone(String id, DateTime deletedAt) =>
      _dao.addTombstoneOnly(id, deletedAt);

  @override
  Future<bool> hasTombstone(String id) => _dao.hasTombstoneForId(id);

  @override
  Future<DateTime?> lastSyncAt() => _dao.getLastSyncAt();

  @override
  Future<void> setLastSyncAt(DateTime t) => _dao.setLastSyncAt(t);
}

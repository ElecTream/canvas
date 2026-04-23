import 'package:drift/drift.dart';

import '../models/note.dart';
import 'app_db.dart';
import 'note_mapper.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [NoteRows, Tombstones, SyncStateRows])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Stream<List<Note>> watchNotes() {
    final q = select(noteRows)
      ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]);
    return q.watch().map((rows) => rows.map(NoteMapper.fromRow).toList());
  }

  Future<List<Note>> getAllNotes() async {
    final rows = await (select(noteRows)
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();
    return rows.map(NoteMapper.fromRow).toList();
  }

  Future<void> upsertNote(Note note,
      {required bool markDirty, DateTime? remoteRev}) async {
    final companion =
        NoteMapper.toCompanion(note, dirty: markDirty, remoteRev: remoteRev);
    await into(noteRows).insertOnConflictUpdate(companion);
  }

  Future<void> deleteNoteLocal(String id, DateTime deletedAt) async {
    await transaction(() async {
      await (delete(noteRows)..where((t) => t.id.equals(id))).go();
      await into(tombstones).insertOnConflictUpdate(
        TombstonesCompanion.insert(id: id, deletedAt: deletedAt),
      );
    });
  }

  Future<bool> isEmpty() async {
    final count = await (selectOnly(noteRows)..addColumns([noteRows.id.count()]))
        .map((row) => row.read(noteRows.id.count()) ?? 0)
        .getSingle();
    return count == 0;
  }

  // --- sync-engine support (Phase 3+) ---

  Future<Note?> getNoteById(String id) async {
    final row = await (select(noteRows)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : NoteMapper.fromRow(row);
  }

  Future<List<Note>> getDirtyNotes() async {
    final rows =
        await (select(noteRows)..where((t) => t.dirty.equals(true))).get();
    return rows.map(NoteMapper.fromRow).toList();
  }

  Future<void> clearDirty(String id, DateTime remoteRev) async {
    await (update(noteRows)..where((t) => t.id.equals(id))).write(
      NoteRowsCompanion(
        dirty: const Value(false),
        remoteRev: Value(remoteRev),
      ),
    );
  }

  /// Sets only the `remoteRev` column. Used by first-push alignment so the
  /// engine doesn't misread "local has id but no known remote rev" as a
  /// conflict when the remote file already exists.
  Future<void> setRemoteRev(String id, DateTime remoteRev) async {
    await (update(noteRows)..where((t) => t.id.equals(id))).write(
      NoteRowsCompanion(remoteRev: Value(remoteRev)),
    );
  }

  Future<DateTime?> getRemoteRev(String id) async {
    final row = await (select(noteRows)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row?.remoteRev;
  }

  Future<void> hardDeleteNote(String id) async {
    await (delete(noteRows)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Tombstone>> getTombstonesWithin(Duration retention) async {
    final cutoff = DateTime.now().toUtc().subtract(retention);
    return (select(tombstones)..where((t) => t.deletedAt.isBiggerThanValue(cutoff)))
        .get();
  }

  Future<void> addTombstoneOnly(String id, DateTime deletedAt) async {
    await into(tombstones).insertOnConflictUpdate(
      TombstonesCompanion.insert(id: id, deletedAt: deletedAt),
    );
  }

  Future<bool> hasTombstoneForId(String id) async {
    final row = await (select(tombstones)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null;
  }

  Future<DateTime?> getLastSyncAt() async {
    final s = await ensureState();
    return s.lastSyncAt;
  }

  Future<void> setLastSyncAt(DateTime t) async {
    await ensureState();
    await (update(syncStateRows)..where((r) => r.id.equals(_stateKey))).write(
      SyncStateRowsCompanion(lastSyncAt: Value(t)),
    );
  }

  Future<DateTime?> getLastOrphanScanAt() async {
    final s = await ensureState();
    return s.lastOrphanScanAt;
  }

  Future<void> setLastOrphanScanAt(DateTime t) async {
    await ensureState();
    await (update(syncStateRows)..where((r) => r.id.equals(_stateKey))).write(
      SyncStateRowsCompanion(lastOrphanScanAt: Value(t)),
    );
  }

  // --- sync_state singleton helpers ---

  static const _stateKey = 0;

  Future<SyncStateRow> ensureState() async {
    final existing = await (select(syncStateRows)
          ..where((t) => t.id.equals(_stateKey)))
        .getSingleOrNull();
    if (existing != null) return existing;
    await into(syncStateRows).insert(
      SyncStateRowsCompanion.insert(id: const Value(_stateKey)),
    );
    return (select(syncStateRows)..where((t) => t.id.equals(_stateKey)))
        .getSingle();
  }

  Future<void> markImportedFromFirestore() async {
    await ensureState();
    await (update(syncStateRows)..where((t) => t.id.equals(_stateKey))).write(
      const SyncStateRowsCompanion(importedFromFirestore: Value(true)),
    );
  }

  Future<bool> hasImportedFromFirestore() async {
    final s = await ensureState();
    return s.importedFromFirestore;
  }

  Future<void> recordLegacyBackup(String path) async {
    await ensureState();
    await (update(syncStateRows)..where((t) => t.id.equals(_stateKey))).write(
      SyncStateRowsCompanion(
        legacyBackupWrittenAt: Value(DateTime.now().toUtc()),
        legacyBackupPath: Value(path),
      ),
    );
  }

  Future<bool> hasFirstDrivePushComplete() async {
    final s = await ensureState();
    return s.firstDrivePushComplete;
  }

  Future<void> markFirstDrivePushComplete() async {
    await ensureState();
    await (update(syncStateRows)..where((t) => t.id.equals(_stateKey))).write(
      const SyncStateRowsCompanion(firstDrivePushComplete: Value(true)),
    );
  }

  Future<void> markAllActiveDirty() async {
    await (update(noteRows)..where((_) => const Constant(true))).write(
      const NoteRowsCompanion(dirty: Value(true)),
    );
  }
}

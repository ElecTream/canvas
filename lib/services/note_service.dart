import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import '../data/notes_dao.dart';
import '../models/note.dart';
import '../sync/debounced_sync_scheduler.dart';

/// drift is sole source of truth. Each save/delete schedules a debounced
/// push to Drive; pulls happen at app boot and via the manual Sync button.
class NoteService {
  NoteService(this._dao, this._scheduler);

  final NotesDao _dao;
  final DebouncedSyncScheduler _scheduler;

  Stream<List<Note>> getNotesStream() => _dao.watchNotes();

  Future<void> saveNote(Note note, {bool isNew = false}) async {
    await _dao.upsertNote(note, markDirty: true);
    _scheduler.schedule();
  }

  /// Soft-delete: mark archived + bump updatedAt so it wins on other devices.
  Future<void> archiveNote(Note note) async {
    final archived = note.copyWith(
      isArchived: true,
      updatedAt: Timestamp.now(),
    );
    await _dao.upsertNote(archived, markDirty: true);
    _scheduler.schedule();
  }

  /// Restore an archived note back into the active list.
  Future<void> restoreNote(Note note) async {
    final restored = note.copyWith(
      isArchived: false,
      updatedAt: Timestamp.now(),
    );
    await _dao.upsertNote(restored, markDirty: true);
    _scheduler.schedule();
  }

  /// Permanent delete. Only reachable from the archive screen.
  Future<void> forceDeleteNote(String id) async {
    await _dao.deleteNoteLocal(id, DateTime.now().toUtc());
    _scheduler.schedule();
  }

  /// Kept for callers that still want the old hard-delete semantic. Prefer
  /// [archiveNote] for the active-list delete entry point.
  Future<void> deleteNote(String id) async {
    await _dao.deleteNoteLocal(id, DateTime.now().toUtc());
    _scheduler.schedule();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db_provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'sync_provider.dart';

final noteServiceProvider = Provider<NoteService>((ref) {
  return NoteService(
    ref.watch(notesDaoProvider),
    ref.watch(debouncedSyncProvider),
  );
});

/// Full, unfiltered stream of notes straight from drift. Screens should
/// prefer [activeNotesProvider] or [archivedNotesProvider] so archived state
/// stays coherent across the UI.
final notesStreamProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(noteServiceProvider).getNotesStream();
});

final activeNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(notesStreamProvider).valueOrNull ?? const [];
  return notes.where((n) => !n.isArchived).toList();
});

final archivedNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(notesStreamProvider).valueOrNull ?? const [];
  return notes.where((n) => n.isArchived).toList();
});

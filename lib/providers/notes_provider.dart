import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../services/note_service.dart';

final noteServiceProvider = Provider<NoteService>((ref) => NoteService());

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  final noteService = ref.watch(noteServiceProvider);
  return NotesNotifier(noteService);
});

class NotesNotifier extends StateNotifier<List<Note>> {
  final NoteService _noteService;

  NotesNotifier(this._noteService) : super([]) {
    loadNotes();
  }

  void loadNotes() {
    state = _noteService.getAllNotes();
  }

  Future<void> addOrUpdateNote(Note note) async {
    await _noteService.saveNote(note);
    final existingNoteIndex = state.indexWhere((n) => n.id == note.id);
    if (existingNoteIndex != -1) {
      state = [
        for (final n in state)
          if (n.id == note.id) note else n,
      ];
    } else {
      state = [note, ...state];
    }
    state.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    state = List.from(state);
  }

  Future<void> deleteNote(String id) async {
    await _noteService.deleteNote(id);
    state = state.where((note) => note.id != id).toList();
  }
}
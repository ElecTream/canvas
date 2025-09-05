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
    loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _noteService.deleteNote(id);
    loadNotes();
  }
}
import 'package:hive/hive.dart';
import '../models/note.dart';

class NoteService {
  final Box<Note> _notesBox = Hive.box<Note>('notes');

  List<Note> getAllNotes() {
    final notes = _notesBox.values.toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Future<void> saveNote(Note note) async {
    note.updatedAt = DateTime.now();
    await _notesBox.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../services/note_service.dart';

// Provides an instance of our NoteService
final noteServiceProvider = Provider<NoteService>((ref) => NoteService());

// The StreamProvider that provides a real-time stream of notes
final notesStreamProvider = StreamProvider<List<Note>>((ref) {
  final noteService = ref.watch(noteServiceProvider);
  return noteService.getNotesStream();
});
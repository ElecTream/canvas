import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's ID
  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return user.uid;
  }

  // Typed collection reference used for reads.
  CollectionReference<Note> get _notesCollection =>
      _firestore.collection('users').doc(_userId).collection('notes').withConverter<Note>(
            fromFirestore: (snapshot, _) => Note.fromJson(snapshot.data()!),
            toFirestore: (note, _) => note.toJson(),
          );

  // Get a real-time stream of notes
  Stream<List<Note>> getNotesStream() {
    return _notesCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Add or update a note.
  ///
  /// Does not mutate [note]. `updatedAt` is always written as a server
  /// timestamp for reliable ordering across clients. Set [isNew] to true
  /// when creating a brand-new note so `createdAt` also uses the server
  /// timestamp; otherwise the existing `note.createdAt` is preserved.
  Future<void> saveNote(Note note, {bool isNew = false}) {
    final data = <String, dynamic>{
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'blocks': note.blocks.map((b) => b.toJson()).toList(),
      'tags': note.tags,
      'attachments': note.attachments,
      'isPinned': note.isPinned,
      'createdAt': isNew ? FieldValue.serverTimestamp() : note.createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes')
        .doc(note.id)
        .set(data);
  }

  // Delete a note
  Future<void> deleteNote(String id) {
    return _notesCollection.doc(id).delete();
  }
}

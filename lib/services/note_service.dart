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

  // Get a reference to the user's notes collection
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

  // Add or update a note
  Future<void> saveNote(Note note) {
    note.updatedAt = Timestamp.now();
    return _notesCollection.doc(note.id).set(note);
  }

  // Delete a note
  Future<void> deleteNote(String id) {
    return _notesCollection.doc(id).delete();
  }
}
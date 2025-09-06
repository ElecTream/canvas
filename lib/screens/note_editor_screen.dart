import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;
    final noteService = ref.read(noteServiceProvider);

    if (title.isEmpty && content.isEmpty) {
      if (_isEditing) {
        noteService.deleteNote(widget.note!.id);
      }
      Navigator.pop(context);
      return;
    }

    final noteToSave = Note(
      id: widget.note?.id,
      title: title.isEmpty ? "Untitled Note" : title,
      content: content,
      // Pass the original createdAt timestamp if editing
      createdAt: widget.note?.createdAt,
    );

    noteService.saveNote(noteToSave);
    Navigator.pop(context);
  }
  
  void _deleteNote() {
    if (_isEditing) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Note?'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(noteServiceProvider).deleteNote(widget.note!.id);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close editor
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.check),
          onPressed: _saveNote,
        ),
        title: Text(_isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteNote,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Title',
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              maxLines: null,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Start writing...',
                ),
                style: const TextStyle(fontSize: 18),
                maxLines: null,
                autofocus: !_isEditing,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
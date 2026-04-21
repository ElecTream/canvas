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
  late final String _initialTitle;
  late final String _initialContent;
  bool _isDirty = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _initialTitle = widget.note?.title ?? '';
    _initialContent = widget.note?.content ?? '';
    _titleController = TextEditingController(text: _initialTitle);
    _contentController = TextEditingController(text: _initialContent);
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final dirty = _titleController.text != _initialTitle ||
        _contentController.text != _initialContent;
    if (dirty != _isDirty) {
      setState(() {
        _isDirty = dirty;
      });
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTextChanged);
    _contentController.removeListener(_onTextChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;
    final noteService = ref.read(noteServiceProvider);

    if (title.isEmpty && content.isEmpty) {
      // Don't silently delete — just pop without saving.
      _isDirty = false;
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

    noteService.saveNote(noteToSave, isNew: !_isEditing);
    _isDirty = false;
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
                final noteService = ref.read(noteServiceProvider);
                final deletedNote = widget.note!;
                noteService.deleteNote(deletedNote.id);
                Navigator.pop(context); // Close dialog

                // Show snackbar on the root ScaffoldMessenger so it survives the pop.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Note deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        noteService.saveNote(deletedNote, isNew: false);
                      },
                    ),
                  ),
                );

                _isDirty = false;
                Navigator.pop(context); // Close editor
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (!mounted) return false;

    switch (result) {
      case 'save':
        _saveNote();
        return false; // _saveNote handles the pop
      case 'discard':
        _isDirty = false;
        Navigator.pop(context);
        return false;
      default:
        return false; // Cancel — stay.
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(_isEditing ? 'Edit Note' : 'New Note'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveNote,
            ),
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
                autofocus: !_isEditing,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/glass_card.dart';
import '../widgets/tag_chip_input.dart';

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
  late final List<String> _initialTags;
  late final bool _initialPinned;
  late final String _heroTag;

  List<String> _tags = [];
  bool _isPinned = false;
  bool _isDirty = false;
  bool _showPreview = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _initialTitle = widget.note?.title ?? '';
    _initialContent = widget.note?.content ?? '';
    _initialTags = List<String>.from(widget.note?.tags ?? const []);
    _initialPinned = widget.note?.isPinned ?? false;
    _tags = List<String>.from(_initialTags);
    _isPinned = _initialPinned;
    _titleController = TextEditingController(text: _initialTitle);
    _contentController = TextEditingController(text: _initialContent);
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
    _heroTag = 'note-${widget.note?.id ?? const Uuid().v4()}';
  }

  void _onTextChanged() => _recomputeDirty();

  void _recomputeDirty() {
    final dirty = _titleController.text != _initialTitle ||
        _contentController.text != _initialContent ||
        !_listEq(_tags, _initialTags) ||
        _isPinned != _initialPinned;
    if (dirty != _isDirty) {
      setState(() => _isDirty = dirty);
    }
  }

  bool _listEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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

    if (title.isEmpty && content.isEmpty && _tags.isEmpty) {
      _isDirty = false;
      Navigator.pop(context);
      return;
    }

    final noteToSave = Note(
      id: widget.note?.id,
      title: title.isEmpty ? 'Untitled Note' : title,
      content: content,
      tags: _tags,
      isPinned: _isPinned,
      createdAt: widget.note?.createdAt,
    );

    noteService.saveNote(noteToSave, isNew: !_isEditing);
    _isDirty = false;
    Navigator.pop(context);
  }

  void _deleteNote() {
    if (!_isEditing) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This cannot be undone from here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final noteService = ref.read(noteServiceProvider);
              final deleted = widget.note!;
              noteService.deleteNote(deleted.id);
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Note deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () => noteService.saveNote(deleted),
                  ),
                ),
              );

              _isDirty = false;
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDiscard() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            child: const Text('Discard', style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    switch (result) {
      case 'save':
        _saveNote();
        break;
      case 'discard':
        _isDirty = false;
        Navigator.pop(context);
        break;
    }
  }

  void _togglePin() {
    setState(() => _isPinned = !_isPinned);
    _recomputeDirty();
  }

  void _togglePreview() {
    FocusScope.of(context).unfocus();
    setState(() => _showPreview = !_showPreview);
  }

  @override
  Widget build(BuildContext context) {
    final teal = Theme.of(context).colorScheme.secondary;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: GlassAppBar(
          leading: const BackButton(),
          title: Text(_isEditing ? 'Edit' : 'New note'),
          actions: [
            IconButton(
              tooltip: _isPinned ? 'Unpin' : 'Pin',
              icon: Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: _isPinned ? teal : null,
              ),
              onPressed: _togglePin,
            ),
            IconButton(
              tooltip: _showPreview ? 'Edit' : 'Preview',
              icon: Icon(_showPreview ? Icons.edit_outlined : Icons.visibility_outlined),
              onPressed: _togglePreview,
            ),
            IconButton(
              tooltip: 'Save',
              icon: const Icon(Icons.check),
              onPressed: _saveNote,
            ),
            if (_isEditing)
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: _deleteNote,
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              bottom: 12,
            ),
            child: Hero(
              tag: _heroTag,
              child: GlassCard(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TagChipInput(
                      tags: _tags,
                      onChanged: (next) {
                        setState(() => _tags = next);
                        _recomputeDirty();
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration.collapsed(hintText: 'Title'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                      maxLines: null,
                      autofocus: !_isEditing,
                    ),
                    const SizedBox(height: 8),
                    Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                    const SizedBox(height: 8),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _showPreview
                            ? _MarkdownPreview(
                                key: const ValueKey('preview'),
                                data: _contentController.text,
                              )
                            : TextField(
                                key: const ValueKey('editor'),
                                controller: _contentController,
                                decoration: const InputDecoration.collapsed(
                                  hintText: 'Start writing… (markdown supported)',
                                ),
                                style: const TextStyle(fontSize: 16, height: 1.55),
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkdownPreview extends StatelessWidget {
  const _MarkdownPreview({super.key, required this.data});
  final String data;

  @override
  Widget build(BuildContext context) {
    if (data.trim().isEmpty) {
      return Center(
        child: Text(
          'Nothing to preview',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        ),
      );
    }

    final teal = Theme.of(context).colorScheme.secondary;
    final config = MarkdownConfig.darkConfig.copy(
      configs: [
        PConfig(textStyle: const TextStyle(fontSize: 16, height: 1.55, color: Colors.white)),
        H1Config(
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        H2Config(
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        H3Config(
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        LinkConfig(style: TextStyle(color: teal, decoration: TextDecoration.underline)),
        CodeConfig(
          style: TextStyle(
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            color: teal,
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
        PreConfig.darkConfig.copy(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(12),
        ),
        BlockquoteConfig(
          sideColor: teal,
          textColor: Colors.white.withValues(alpha: 0.85),
        ),
      ],
    );

    return MarkdownWidget(
      data: data,
      shrinkWrap: false,
      padding: EdgeInsets.zero,
      config: config,
    );
  }
}

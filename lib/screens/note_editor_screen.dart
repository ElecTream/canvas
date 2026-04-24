import 'dart:async';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../providers/image_provider.dart';
import '../providers/notes_provider.dart';
import '../utils/app_snackbar.dart';
import '../widgets/attachment_strip.dart';
import '../widgets/block_editor.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/glass_card.dart';
import '../widgets/markdown_guide.dart';
import '../widgets/tag_chip_input.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen>
    with WidgetsBindingObserver {
  late final TextEditingController _titleController;
  late String _initialTitle;
  late List<String> _initialTags;
  late List<String> _initialAttachments;
  late List<NoteBlock> _initialBlocks;
  late bool _initialPinned;
  late final String _heroTag;

  final GlobalKey<BlockEditorState> _blockEditorKey =
      GlobalKey<BlockEditorState>();

  List<String> _tags = [];
  List<String> _attachments = [];
  List<NoteBlock> _blocks = [];
  bool _isPinned = false;
  bool _isDirty = false;
  // Existing notes open rendered; new notes open in source mode so the
  // keyboard can appear immediately.
  late bool _previewMode;
  bool _showAttachments = false;
  Timer? _autosaveDebounce;

  // After a new-note autosave, the generated id lives here so subsequent
  // autosaves upsert the same row instead of inserting a new one each time
  // (otherwise typing "hello" with a 2s debounce spawns N duplicate rows).
  String? _persistedId;

  bool get _isEditing => widget.note != null;
  String? get _currentId => widget.note?.id ?? _persistedId;

  @override
  void initState() {
    super.initState();
    _initialTitle = widget.note?.title ?? '';
    _initialTags = List<String>.from(widget.note?.tags ?? const []);
    _initialAttachments =
        List<String>.from(widget.note?.attachments ?? const []);
    _initialBlocks = widget.note?.blocks != null
        ? List<NoteBlock>.from(widget.note!.blocks)
        : const [TextBlock('')];
    _initialPinned = widget.note?.isPinned ?? false;
    _tags = List<String>.from(_initialTags);
    _attachments = List<String>.from(_initialAttachments);
    _blocks = List<NoteBlock>.from(_initialBlocks);
    _isPinned = _initialPinned;
    _previewMode = _isEditing;
    _titleController = TextEditingController(text: _initialTitle);
    _titleController.addListener(_recomputeDirty);
    _heroTag = 'note-${widget.note?.id ?? const Uuid().v4()}';
    WidgetsBinding.instance.addObserver(this);
  }

  void _enterSourceMode() => _enterSourceModeAt(null);

  void _enterSourceModeAt(int? textIndex, {int? charOffset}) {
    if (!_previewMode) return;
    setState(() => _previewMode = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (textIndex == null) {
        _blockEditorKey.currentState?.focusLastTextBlock();
      } else {
        _blockEditorKey.currentState
            ?.focusTextBlockAt(textIndex, charOffset: charOffset);
      }
    });
  }

  // Preview-mode long-press on an inline image: flip to source mode, then
  // pop the same image-options sheet the edit mode uses.
  void _enterSourceModeAndShowImageMenu(String name) {
    if (_previewMode) setState(() => _previewMode = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _blockEditorKey.currentState?.showImageMenuFor(name);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      if (_isDirty) _silentSave();
    }
  }

  void _recomputeDirty() {
    final dirty = _titleController.text != _initialTitle ||
        !_listEq(_tags, _initialTags) ||
        !_listEq(_attachments, _initialAttachments) ||
        !_blocksEq(_blocks, _initialBlocks) ||
        _isPinned != _initialPinned;
    if (dirty != _isDirty) {
      setState(() => _isDirty = dirty);
    }
    if (dirty) {
      _autosaveDebounce?.cancel();
      _autosaveDebounce = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        if (_isDirty) _silentSave();
      });
    }
  }

  bool _listEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _blocksEq(List<NoteBlock> a, List<NoteBlock> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _autosaveDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (_isDirty) _silentSave();
    _titleController.removeListener(_recomputeDirty);
    _titleController.dispose();
    super.dispose();
  }

  bool _isEffectivelyEmpty() {
    if (_titleController.text.isNotEmpty) return false;
    if (_tags.isNotEmpty) return false;
    if (_attachments.isNotEmpty) return false;
    for (final b in _blocks) {
      if (b is ImageBlock) return false;
      if (b is TextBlock && b.text.isNotEmpty) return false;
    }
    return true;
  }

  void _saveNote() {
    final title = _titleController.text;
    final noteService = ref.read(noteServiceProvider);

    if (_isEffectivelyEmpty()) {
      _isDirty = false;
      Navigator.pop(context);
      return;
    }

    final id = _currentId ?? const Uuid().v4();
    _persistedId ??= id;
    final noteToSave = Note(
      id: id,
      title: title.isEmpty ? 'Untitled Note' : title,
      blocks: _blocks,
      tags: _tags,
      attachments: _attachments,
      isPinned: _isPinned,
      createdAt: widget.note?.createdAt,
    );

    noteService.saveNote(noteToSave, isNew: !_isEditing);
    _isDirty = false;
    Navigator.pop(context);
  }

  void _silentSave() {
    if (_isEffectivelyEmpty()) return;
    final noteService = ref.read(noteServiceProvider);
    final title = _titleController.text;
    final id = _currentId ?? const Uuid().v4();
    _persistedId ??= id;
    final noteToSave = Note(
      id: id,
      title: title.isEmpty ? 'Untitled Note' : title,
      blocks: _blocks,
      tags: _tags,
      attachments: _attachments,
      isPinned: _isPinned,
      createdAt: widget.note?.createdAt,
    );
    noteService.saveNote(noteToSave, isNew: !_isEditing);
    _initialTitle = title;
    _initialTags = List<String>.from(_tags);
    _initialAttachments = List<String>.from(_attachments);
    _initialBlocks = List<NoteBlock>.from(_blocks);
    _initialPinned = _isPinned;
    if (mounted) setState(() => _isDirty = false);
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

              showAppSnack(
                context,
                'Note deleted',
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () => noteService.saveNote(deleted),
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

  void _togglePin() {
    setState(() => _isPinned = !_isPinned);
    _recomputeDirty();
  }

  bool get _desktopDropSupported =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  void _attachName(String name) {
    setState(() => _attachments = [..._attachments, name]);
    _recomputeDirty();
  }

  void _onBlocksChanged(List<NoteBlock> blocks) {
    _blocks = blocks;
    _recomputeDirty();
  }

  void _insertInline(String name) {
    _blockEditorKey.currentState?.insertImageAtCursor(name);
  }

  void _removeEverywhere(String name) {
    _blockEditorKey.currentState?.removeAllImages(name);
  }

  Widget _wrapWithDrop({required Widget child}) {
    if (!_desktopDropSupported) return child;
    return DropTarget(
      onDragDone: (d) => _onDesktopDrop(d.files),
      child: child,
    );
  }

  Future<void> _onDesktopDrop(List<XFile> files) async {
    if (files.isEmpty) return;
    final service = ref.read(imageServiceProvider);
    for (final f in files) {
      final ext = f.path.toLowerCase();
      if (!ext.endsWith('.jpg') &&
          !ext.endsWith('.jpeg') &&
          !ext.endsWith('.png') &&
          !ext.endsWith('.webp') &&
          !ext.endsWith('.gif') &&
          !ext.endsWith('.bmp')) {
        continue;
      }
      try {
        final bytes = await File(f.path).readAsBytes();
        final name = await service.saveBytes(bytes);
        if (!mounted) return;
        _attachName(name);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final teal = Theme.of(context).colorScheme.secondary;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        _autosaveDebounce?.cancel();
        if (_isDirty) _silentSave();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: GlassAppBar(
          leading: const BackButton(),
          title: Text(_isEditing ? 'Edit' : 'New note'),
          actions: [
            IconButton(
              tooltip: _previewMode ? 'Edit source' : 'Rendered view',
              icon: Icon(_previewMode ? Icons.edit_note : Icons.visibility),
              onPressed: () => setState(() => _previewMode = !_previewMode),
            ),
            IconButton(
              tooltip: 'Markdown help',
              icon: const Icon(Icons.help_outline),
              onPressed: () => showMarkdownGuide(context),
            ),
            IconButton(
              tooltip: _showAttachments ? 'Hide photos' : 'Show photos',
              icon: Badge.count(
                count: _attachments.length,
                isLabelVisible: _attachments.isNotEmpty,
                child: Icon(_showAttachments
                    ? Icons.photo_library
                    : Icons.photo_library_outlined),
              ),
              onPressed: () =>
                  setState(() => _showAttachments = !_showAttachments),
            ),
            IconButton(
              tooltip: _isPinned ? 'Unpin' : 'Pin',
              icon: Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: _isPinned ? teal : null,
              ),
              onPressed: _togglePin,
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
        body: _wrapWithDrop(
          child: SafeArea(
            top: false,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Padding(
                padding: EdgeInsets.only(
                  top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  right: 12,
                  bottom: 12,
                ),
                child: Hero(
                  tag: _heroTag,
                  child: GestureDetector(
                    behavior: HitTestBehavior.deferToChild,
                    onTap: () =>
                        _blockEditorKey.currentState?.focusLastTextBlock(),
                    child: GlassCard(
                      readable: true,
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
                            decoration: const InputDecoration.collapsed(
                                hintText: 'Title'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                            maxLines: null,
                            autofocus: !_isEditing,
                          ),
                          const SizedBox(height: 8),
                          Divider(
                            color: Colors.white.withValues(alpha: 0.08),
                            height: 1,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              child: _previewMode
                                  ? _PreviewBody(
                                      blocks: _blocks,
                                      accent: teal,
                                      onTextBlockTap: (index, offset) =>
                                          _enterSourceModeAt(index,
                                              charOffset: offset),
                                      onEmptyTap: _enterSourceMode,
                                      onImageLongPress:
                                          _enterSourceModeAndShowImageMenu,
                                    )
                                  : BlockEditor(
                                      key: _blockEditorKey,
                                      initialBlocks: _initialBlocks,
                                      allAttachments: _attachments,
                                      onChanged: _onBlocksChanged,
                                      onRemoveImageEverywhere: (name) {
                                        setState(() {
                                          _attachments = _attachments
                                              .where((n) => n != name)
                                              .toList();
                                        });
                                        _recomputeDirty();
                                      },
                                    ),
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            child: _showAttachments
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 8),
                                      Divider(
                                        color: Colors.white
                                            .withValues(alpha: 0.08),
                                        height: 1,
                                      ),
                                      AttachmentStrip(
                                        names: _attachments,
                                        onChange: (next) {
                                          setState(() => _attachments = next);
                                          _recomputeDirty();
                                        },
                                        onInsertInline: _insertInline,
                                        onRemoveEverywhere: _removeEverywhere,
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewBody extends ConsumerWidget {
  const _PreviewBody({
    required this.blocks,
    required this.accent,
    required this.onTextBlockTap,
    required this.onEmptyTap,
    required this.onImageLongPress,
  });

  final List<NoteBlock> blocks;
  final Color accent;
  final void Function(int textIndex, int charOffset) onTextBlockTap;
  final VoidCallback onEmptyTap;
  final void Function(String name) onImageLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageService = ref.watch(imageServiceProvider);
    final body = Colors.white.withValues(alpha: 0.88);
    final config = MarkdownConfig.darkConfig.copy(
      configs: [
        PConfig(textStyle: TextStyle(fontSize: 15, height: 1.55, color: body)),
        H1Config(
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.3),
        ),
        H2Config(
          style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.3),
        ),
        H3Config(
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.3),
        ),
        LinkConfig(
            style: TextStyle(
                color: accent,
                decoration: TextDecoration.underline,
                fontSize: 15)),
        CodeConfig(
          style: TextStyle(
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            color: accent,
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
        PreConfig.darkConfig.copy(
          textStyle: TextStyle(
              color: body, fontSize: 13, fontFamily: 'monospace', height: 1.4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(10),
        ),
        BlockquoteConfig(sideColor: accent, textColor: body),
      ],
    );

    final children = <Widget>[];
    int textIndex = 0;
    for (final b in blocks) {
      if (b is TextBlock) {
        final currentIdx = textIndex;
        textIndex++;
        if (b.text.trim().isEmpty) continue;
        children.add(LayoutBuilder(
          builder: (ctx, constraints) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) {
              final offset = _offsetFromTap(
                  b.text, d.localPosition, constraints.maxWidth);
              onTextBlockTap(currentIdx, offset);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: IgnorePointer(
                // Swallow in-block gestures (link taps, selection) so our
                // tap-to-edit wins. If selectable preview is ever wanted
                // again, promote to a long-press entry instead.
                child: MarkdownBlock(
                  data: b.text,
                  selectable: false,
                  config: config,
                ),
              ),
            ),
          ),
        ));
      } else if (b is ImageBlock) {
        final file = imageService.resolveSync(b.name);
        if (!file.existsSync()) continue;
        final rev = imageService.revisionFor(b.name);
        children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () => onImageLongPress(b.name),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Image.file(
                  file,
                  key: ValueKey('img-${b.name}-$rev'),
                  fit: BoxFit.contain,
                  cacheWidth: 800,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
        ));
      }
    }

    if (children.isEmpty) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onEmptyTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Nothing to preview',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          ),
        ),
      );
    }

    // A translucent gutter at the bottom so tapping below the last block
    // still enters source mode (at end of last text block).
    children.add(GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onEmptyTap,
      child: const SizedBox(height: 120),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  int _offsetFromTap(String text, Offset tap, double maxWidth) {
    if (text.isEmpty) return 0;
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 16, height: 1.55),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    final pos = painter.getPositionForOffset(tap);
    return pos.offset.clamp(0, text.length);
  }
}

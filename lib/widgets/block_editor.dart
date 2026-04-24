import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';
import '../providers/image_provider.dart';
import '../services/image_service.dart';
import '../theme/surface_colors.dart';
import '../utils/app_snackbar.dart';
import 'glass_card.dart';
import 'image_viewer.dart';
import 'markdown_input_helpers.dart';

class BlockEditor extends ConsumerStatefulWidget {
  const BlockEditor({
    super.key,
    required this.initialBlocks,
    required this.onChanged,
    required this.onRemoveImageEverywhere,
    required this.allAttachments,
  });

  final List<NoteBlock> initialBlocks;
  final ValueChanged<List<NoteBlock>> onChanged;
  final ValueChanged<String> onRemoveImageEverywhere;
  final List<String> allAttachments;

  @override
  ConsumerState<BlockEditor> createState() => BlockEditorState();
}

class _Entry {
  _Entry.text({
    required this.id,
    required this.controller,
    required this.focus,
  })  : isImage = false,
        name = null,
        width = 1.0,
        newRow = false;

  _Entry.image(this.name, {this.width = 0.5, this.newRow = false})
      : id = const Uuid().v4(),
        isImage = true,
        controller = null,
        focus = null;

  final String id;
  final bool isImage;
  final TextEditingController? controller;
  final FocusNode? focus;
  final String? name;
  double width;
  bool newRow;
}

class BlockEditorState extends ConsumerState<BlockEditor> {
  final List<_Entry> _entries = [];
  _Entry? _activeText;

  @override
  void initState() {
    super.initState();
    _entries.addAll(_buildEntries(widget.initialBlocks));
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.controller?.dispose();
      e.focus?.dispose();
    }
    super.dispose();
  }

  List<_Entry> _buildEntries(List<NoteBlock> blocks) {
    final out = <_Entry>[];
    for (final b in blocks) {
      if (b is TextBlock) {
        out.add(_makeText(b.text));
      } else if (b is ImageBlock) {
        out.add(_Entry.image(b.name, width: b.width, newRow: b.newRow));
      }
    }
    if (out.isEmpty || out.last.isImage) {
      out.add(_makeText(''));
    }
    return out;
  }

  _Entry _makeText(String text) {
    final id = const Uuid().v4();
    final controller = MarkdownInputController(text: text);
    final focus = FocusNode();
    final entry = _Entry.text(id: id, controller: controller, focus: focus);
    controller.addListener(_notifyChanged);
    focus.addListener(() {
      if (focus.hasFocus) _activeText = entry;
    });
    return entry;
  }

  void _notifyChanged() {
    widget.onChanged(_serialize());
  }

  List<NoteBlock> _serialize() {
    return _entries.map<NoteBlock>((e) {
      if (e.isImage) {
        return ImageBlock(e.name!, width: e.width, newRow: e.newRow);
      }
      return TextBlock(e.controller!.text);
    }).toList();
  }

  void insertImageAtCursor(String name) {
    _Entry? target = _activeText;
    if (target == null || target.isImage) {
      target = _entries.cast<_Entry?>().lastWhere(
            (e) => e != null && !e.isImage,
            orElse: () => null,
          );
    }

    if (target == null) {
      setState(() {
        _entries.add(_Entry.image(name));
        _entries.add(_makeText(''));
      });
      _afterStructuralChange(focusEntry: _entries.last);
      return;
    }

    final ctrl = target.controller!;
    final sel = ctrl.selection;
    final offset = sel.isValid
        ? sel.baseOffset.clamp(0, ctrl.text.length)
        : ctrl.text.length;
    final before = ctrl.text.substring(0, offset);
    final after = ctrl.text.substring(offset);
    final idx = _entries.indexOf(target);
    final trailing = _makeText(after);

    setState(() {
      ctrl.removeListener(_notifyChanged);
      ctrl.text = before;
      ctrl.addListener(_notifyChanged);
      _entries.insert(idx + 1, _Entry.image(name));
      _entries.insert(idx + 2, trailing);
    });

    _afterStructuralChange(focusEntry: trailing, cursorOffset: 0);
  }

  void removeAllImages(String name) {
    if (!_entries.any((e) => e.isImage && e.name == name)) return;
    setState(() {
      int i = 0;
      while (i < _entries.length) {
        if (_entries[i].isImage && _entries[i].name == name) {
          _entries.removeAt(i);
          _mergeAdjacentTextAt(i);
        } else {
          i++;
        }
      }
      _ensureTrailingText();
    });
    _notifyChanged();
  }

  void _removeFromNote(int index) {
    setState(() {
      _entries.removeAt(index);
      _mergeAdjacentTextAt(index);
      _ensureTrailingText();
    });
    _notifyChanged();
  }

  void _removeEverywhere(int index) {
    final name = _entries[index].name!;
    widget.onRemoveImageEverywhere(name);
    removeAllImages(name);
  }

  void _moveImage(int from, int delta) {
    final to = from + delta;
    if (to < 0 || to >= _entries.length) return;
    setState(() {
      final entry = _entries.removeAt(from);
      _entries.insert(to, entry);
    });
    _notifyChanged();
  }

  void _mergeAdjacentTextAt(int pivot) {
    final leftIdx = pivot - 1;
    final rightIdx = pivot;
    if (leftIdx < 0 || rightIdx >= _entries.length) return;
    final left = _entries[leftIdx];
    final right = _entries[rightIdx];
    if (left.isImage || right.isImage) return;

    final combined = left.controller!.text.isEmpty
        ? right.controller!.text
        : right.controller!.text.isEmpty
            ? left.controller!.text
            : '${left.controller!.text}\n${right.controller!.text}';

    left.controller!.removeListener(_notifyChanged);
    left.controller!.text = combined;
    left.controller!.addListener(_notifyChanged);

    right.controller!.dispose();
    right.focus!.dispose();
    _entries.removeAt(rightIdx);
  }

  void _ensureTrailingText() {
    if (_entries.isEmpty || _entries.last.isImage) {
      _entries.add(_makeText(''));
    }
  }

  void _afterStructuralChange({_Entry? focusEntry, int? cursorOffset}) {
    _notifyChanged();
    if (focusEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        focusEntry.focus?.requestFocus();
        if (cursorOffset != null) {
          focusEntry.controller?.selection =
              TextSelection.collapsed(offset: cursorOffset);
        }
      });
    }
  }

  Future<void> _editImageAt(int index) async {
    final entry = _entries[index];
    final service = ref.read(imageServiceProvider);
    final file = service.resolveSync(entry.name!);

    // image_cropper ships native Android/iOS UI only; desktop/web fall back
    // to a polite no-op snack so the feature doesn't crash off-platform.
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      showAppSnack(context, 'Image editing only available on Android / iOS',
          duration: const Duration(seconds: 2));
      return;
    }

    final accent = Theme.of(context).colorScheme.secondary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!await file.exists()) return;

    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: file.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 92,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit image',
            toolbarColor: isDark ? Colors.black : Colors.white,
            toolbarWidgetColor: isDark ? Colors.white : Colors.black,
            statusBarLight: !isDark,
            backgroundColor: isDark ? Colors.black : Colors.white,
            activeControlsWidgetColor: accent,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            aspectRatioPresets: const [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Edit image',
            aspectRatioLockEnabled: false,
            aspectRatioPresets: const [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );
      if (cropped == null) return;
      final bytes = await File(cropped.path).readAsBytes();
      await service.overwriteBytes(entry.name!, bytes);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        showAppSnack(context, 'Edit failed: $e',
            duration: const Duration(seconds: 2));
      }
    }
  }

  /// Public entry point used by preview-mode long-press. Looks up the first
  /// entry matching [name] and opens the same image menu edit-mode uses.
  Future<void> showImageMenuFor(String name) async {
    final idx = _entries.indexWhere((e) => e.isImage && e.name == name);
    if (idx < 0) return;
    await _showImageMenu(idx);
  }

  Future<void> _showImageMenu(int index) async {
    final hasPrev = index > 0;
    final hasNext = index < _entries.length - 1;
    final prevIsImage = hasPrev && _entries[index - 1].isImage;
    final currentWidth = _entries[index].width;
    final currentNewRow = _entries[index].newRow;

    final choice = await showModalBottomSheet<_ImageMenuAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            readable: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: const Text('Edit image'),
                  subtitle: const Text('Crop, rotate'),
                  onTap: () => Navigator.pop(ctx, _ImageMenuAction.edit),
                ),
                _SizePicker(
                  current: currentWidth,
                  onPick: (w) => Navigator.pop(ctx, _ImageMenuAction.size(w)),
                ),
                if (prevIsImage)
                  ListTile(
                    leading: Icon(currentNewRow
                        ? Icons.view_week
                        : Icons.view_agenda),
                    title: Text(currentNewRow
                        ? 'Join row above'
                        : 'Break to own row'),
                    onTap: () =>
                        Navigator.pop(ctx, _ImageMenuAction.toggleRowBreak),
                  ),
                if (hasPrev)
                  ListTile(
                    leading: const Icon(Icons.arrow_upward),
                    title: const Text('Move up'),
                    onTap: () => Navigator.pop(ctx, _ImageMenuAction.moveUp),
                  ),
                if (hasNext)
                  ListTile(
                    leading: const Icon(Icons.arrow_downward),
                    title: const Text('Move down'),
                    onTap: () => Navigator.pop(ctx, _ImageMenuAction.moveDown),
                  ),
                ListTile(
                  leading: const Icon(Icons.remove_circle_outline),
                  title: const Text('Remove from note'),
                  subtitle: const Text('Keeps image in carousel'),
                  onTap: () => Navigator.pop(ctx, _ImageMenuAction.removeNote),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Remove everywhere',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  subtitle: const Text('Removes from note and carousel'),
                  onTap: () => Navigator.pop(ctx, _ImageMenuAction.removeAll),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (choice == null || !mounted) return;

    switch (choice.kind) {
      case _ImageMenuKind.edit:
        await _editImageAt(index);
        break;
      case _ImageMenuKind.size:
        setState(() => _entries[index].width = choice.width!);
        _notifyChanged();
        break;
      case _ImageMenuKind.toggleRowBreak:
        setState(() => _entries[index].newRow = !_entries[index].newRow);
        _notifyChanged();
        break;
      case _ImageMenuKind.moveUp:
        _moveImage(index, -1);
        break;
      case _ImageMenuKind.moveDown:
        _moveImage(index, 1);
        break;
      case _ImageMenuKind.removeNote:
        _removeFromNote(index);
        break;
      case _ImageMenuKind.removeAll:
        _removeEverywhere(index);
        break;
    }

    if (mounted) FocusScope.of(context).unfocus();
    Future.microtask(() {
      if (!mounted) return;
      final nearest = _entries.cast<_Entry?>().firstWhere(
            (e) => e != null && !e.isImage,
            orElse: () => null,
          );
      nearest?.focus?.requestFocus();
    });
  }

  void _openViewerFor(String name) {
    final service = ref.read(imageServiceProvider);
    final names = widget.allAttachments;
    final idx = names.indexOf(name);
    openImageViewer(context, service, names, idx < 0 ? 0 : idx);
  }

  void focusLastTextBlock({bool placeAtEnd = true}) {
    final target = _entries.cast<_Entry?>().lastWhere(
          (e) => e != null && !e.isImage,
          orElse: () => null,
        );
    if (target == null) return;
    target.focus!.requestFocus();
    if (placeAtEnd) {
      final ctrl = target.controller!;
      ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
    }
  }

  /// Focus the nth text block (image entries skipped). If [charOffset] is
  /// provided, the caret lands at that offset, clamped to the block's text
  /// length; otherwise the caret goes to the end. Falls back to
  /// [focusLastTextBlock] when [textIndex] is out of range.
  void focusTextBlockAt(int textIndex, {int? charOffset}) {
    int seen = 0;
    for (final e in _entries) {
      if (e.isImage) continue;
      if (seen == textIndex) {
        e.focus!.requestFocus();
        final ctrl = e.controller!;
        final offset = (charOffset ?? ctrl.text.length).clamp(0, ctrl.text.length);
        ctrl.selection = TextSelection.collapsed(offset: offset);
        return;
      }
      seen++;
    }
    focusLastTextBlock();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    int i = 0;
    while (i < _entries.length) {
      final e = _entries[i];
      if (e.isImage) {
        final rowEntries = <MapEntry<int, _Entry>>[MapEntry(i, e)];
        int j = i + 1;
        while (j < _entries.length &&
            _entries[j].isImage &&
            !_entries[j].newRow) {
          rowEntries.add(MapEntry(j, _entries[j]));
          j++;
        }
        children.add(_ImageRow(
          key: ValueKey('row-${e.id}'),
          entries: rowEntries,
          onTapIndex: _openViewerFor,
          onLongPressIndex: _showImageMenu,
          onWidthChanged: (index, next) {
            setState(() => _entries[index].width = next);
            _notifyChanged();
          },
        ));
        i = j;
      } else {
        children.add(
          TextField(
            key: ValueKey('txt-${e.id}'),
            controller: e.controller,
            focusNode: e.focus,
            decoration: InputDecoration.collapsed(
              hintText: i == 0 ? 'Start writing…' : '',
            ),
            style: const TextStyle(fontSize: 16, height: 1.55),
            maxLines: null,
            minLines: 1,
            textAlignVertical: TextAlignVertical.top,
            keyboardType: TextInputType.multiline,
          ),
        );
        i++;
      }
    }

    children.add(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => focusLastTextBlock(),
        child: const SizedBox(height: 140),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

enum _ImageMenuKind {
  edit,
  size,
  toggleRowBreak,
  moveUp,
  moveDown,
  removeNote,
  removeAll,
}

class _ImageMenuAction {
  const _ImageMenuAction._(this.kind, {this.width});
  final _ImageMenuKind kind;
  final double? width;

  static const edit = _ImageMenuAction._(_ImageMenuKind.edit);
  static const toggleRowBreak =
      _ImageMenuAction._(_ImageMenuKind.toggleRowBreak);
  static const moveUp = _ImageMenuAction._(_ImageMenuKind.moveUp);
  static const moveDown = _ImageMenuAction._(_ImageMenuKind.moveDown);
  static const removeNote = _ImageMenuAction._(_ImageMenuKind.removeNote);
  static const removeAll = _ImageMenuAction._(_ImageMenuKind.removeAll);
  static _ImageMenuAction size(double w) =>
      _ImageMenuAction._(_ImageMenuKind.size, width: w);
}

class _SizePicker extends StatelessWidget {
  const _SizePicker({required this.current, required this.onPick});
  final double current;
  final ValueChanged<double> onPick;

  @override
  Widget build(BuildContext context) {
    const options = [0.25, 0.5, 0.75, 1.0];
    final accent = Theme.of(context).colorScheme.secondary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        children: [
          Icon(Icons.aspect_ratio, color: onSurfaceMuted(context, 0.7)),
          const SizedBox(width: 16),
          const Text('Size', style: TextStyle(fontSize: 16)),
          const Spacer(),
          ...options.map((o) {
            final selected = (current - o).abs() < 0.01;
            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onPick(o),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? accent.withValues(alpha: 0.22)
                        : surfaceTint(context, 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(o * 100).round()}%',
                    style: TextStyle(
                      color: selected
                          ? accent
                          : onSurfaceMuted(context, 0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ImageRow extends ConsumerWidget {
  const _ImageRow({
    super.key,
    required this.entries,
    required this.onTapIndex,
    required this.onLongPressIndex,
    required this.onWidthChanged,
  });

  final List<MapEntry<int, _Entry>> entries;
  final void Function(String name) onTapIndex;
  final Future<void> Function(int index) onLongPressIndex;
  final void Function(int index, double width) onWidthChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final parentW = constraints.maxWidth;
      const gap = 6.0;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Wrap(
          spacing: gap,
          runSpacing: gap,
          children: entries.map((me) {
            final idx = me.key;
            final entry = me.value;
            final tileW = (parentW * entry.width) - (gap / 2);
            return SizedBox(
              width: tileW.clamp(64.0, parentW),
              child: _ResizableInlineImage(
                name: entry.name!,
                width: entry.width,
                parentWidth: parentW,
                onTap: () => onTapIndex(entry.name!),
                onLongPress: () => onLongPressIndex(idx),
                onWidthChanged: (next) => onWidthChanged(idx, next),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

class _ResizableInlineImage extends ConsumerStatefulWidget {
  const _ResizableInlineImage({
    required this.name,
    required this.width,
    required this.parentWidth,
    required this.onTap,
    required this.onLongPress,
    required this.onWidthChanged,
  });

  final String name;
  final double width;
  final double parentWidth;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<double> onWidthChanged;

  @override
  ConsumerState<_ResizableInlineImage> createState() =>
      _ResizableInlineImageState();
}

class _ResizableInlineImageState
    extends ConsumerState<_ResizableInlineImage> {
  double? _dragStartFraction;
  double? _dragStartX;

  @override
  Widget build(BuildContext context) {
    final ImageService service = ref.watch(imageServiceProvider);
    final file = service.resolveSync(widget.name);
    final exists = file.existsSync();
    final maxH = MediaQuery.of(context).size.height * 0.6;
    final rev = service.revisionFor(widget.name);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                child: exists
                    ? Hero(
                        tag: 'image-${file.path}',
                        child: Image.file(
                          file,
                          key: ValueKey('img-${widget.name}-$rev'),
                          fit: BoxFit.contain,
                          cacheWidth: 800,
                          gaplessPlayback: true,
                        ),
                      )
                    : SizedBox(
                        height: 160,
                        child: Container(
                          color: surfaceTint(context, 0.05),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: onSurfaceMuted(context, 0.4),
                            size: 36,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: 22,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (d) {
                _dragStartFraction = widget.width;
                _dragStartX = d.globalPosition.dx;
              },
              onHorizontalDragUpdate: (d) {
                if (_dragStartFraction == null || _dragStartX == null) return;
                if (widget.parentWidth <= 0) return;
                final delta = d.globalPosition.dx - _dragStartX!;
                final next =
                    (_dragStartFraction! + delta / widget.parentWidth)
                        .clamp(0.2, 1.0);
                widget.onWidthChanged(next);
              },
              onHorizontalDragEnd: (_) {
                _dragStartFraction = null;
                _dragStartX = null;
              },
              child: Center(
                child: Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: surfaceTint(context, 0.55),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

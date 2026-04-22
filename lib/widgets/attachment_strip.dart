import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/image_provider.dart';
import '../services/image_service.dart';
import 'glass_card.dart';
import 'image_viewer.dart';

bool get _supportsCamera =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

class AttachmentStrip extends ConsumerWidget {
  const AttachmentStrip({
    super.key,
    required this.names,
    required this.onChange,
    required this.onInsertInline,
    required this.onRemoveEverywhere,
  });

  final List<String> names;
  final ValueChanged<List<String>> onChange;

  /// Tap a thumb: request that the parent insert the image inline at cursor.
  final ValueChanged<String> onInsertInline;

  /// The user chose Delete on a carousel thumb — the parent must also strip
  /// every inline placement of that image.
  final ValueChanged<String> onRemoveEverywhere;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(imageServiceProvider);

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        itemCount: names.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == names.length) {
            return _AddButton(
              onTap: () => _showAddSheet(context, ref, service),
            );
          }
          return _Thumb(
            name: names[i],
            position: i + 1,
            onTap: () => onInsertInline(names[i]),
            onLongPress: () => _showItemMenu(context, ref, service, i),
          );
        },
      ),
    );
  }

  Future<void> _showAddSheet(
    BuildContext context,
    WidgetRef ref,
    ImageService service,
  ) async {
    final choice = await showModalBottomSheet<_AddSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Gallery'),
                  subtitle: const Text('Pick one or more'),
                  onTap: () => Navigator.pop(ctx, _AddSource.gallery),
                ),
                if (_supportsCamera)
                  ListTile(
                    leading: const Icon(Icons.photo_camera_outlined),
                    title: const Text('Camera'),
                    onTap: () => Navigator.pop(ctx, _AddSource.camera),
                  ),
                ListTile(
                  leading: const Icon(Icons.content_paste),
                  title: const Text('Paste from clipboard'),
                  onTap: () => Navigator.pop(ctx, _AddSource.paste),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (choice == null || !context.mounted) return;

    switch (choice) {
      case _AddSource.gallery:
        await _pickMultiGallery(context, service);
        break;
      case _AddSource.camera:
        await _pickCameraSingle(context, service);
        break;
      case _AddSource.paste:
        await _pasteFromClipboard(context, service);
        break;
    }
  }

  Future<void> _pickMultiGallery(
    BuildContext context,
    ImageService service,
  ) async {
    try {
      final files = await service.pickGalleryMulti();
      if (files.isEmpty) return;
      final next = List<String>.from(names);
      for (final x in files) {
        final bytes = await x.readAsBytes();
        final name = await service.saveBytes(bytes);
        next.add(name);
      }
      onChange(next);
    } catch (e) {
      if (context.mounted) _snack(context, 'Picker failed: $e');
    }
  }

  Future<void> _pickCameraSingle(
    BuildContext context,
    ImageService service,
  ) async {
    try {
      final xfile = await service.pickCamera();
      if (xfile == null) return;
      final bytes = await xfile.readAsBytes();
      final name = await service.saveBytes(bytes);
      onChange([...names, name]);
    } catch (e) {
      if (context.mounted) _snack(context, 'Camera failed: $e');
    }
  }

  Future<void> _pasteFromClipboard(
    BuildContext context,
    ImageService service,
  ) async {
    try {
      final bytes = await service.readClipboardImage();
      if (bytes == null) {
        if (context.mounted) _snack(context, 'No image in clipboard');
        return;
      }
      final name = await service.saveBytes(bytes);
      onChange([...names, name]);
    } catch (e) {
      if (context.mounted) _snack(context, 'Paste failed: $e');
    }
  }

  Future<void> _showItemMenu(
    BuildContext context,
    WidgetRef ref,
    ImageService service,
    int index,
  ) async {
    final choice = await showModalBottomSheet<_ItemAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index > 0)
                  ListTile(
                    leading: const Icon(Icons.arrow_back),
                    title: const Text('Move left'),
                    onTap: () => Navigator.pop(ctx, _ItemAction.moveLeft),
                  ),
                if (index < names.length - 1)
                  ListTile(
                    leading: const Icon(Icons.arrow_forward),
                    title: const Text('Move right'),
                    onTap: () => Navigator.pop(ctx, _ItemAction.moveRight),
                  ),
                ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: const Text('View'),
                  onTap: () => Navigator.pop(ctx, _ItemAction.view),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  subtitle: const Text('Removes from note and carousel'),
                  onTap: () => Navigator.pop(ctx, _ItemAction.delete),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (choice == null || !context.mounted) return;

    switch (choice) {
      case _ItemAction.delete:
        final removedName = names[index];
        onRemoveEverywhere(removedName);
        final next = List<String>.from(names)..removeAt(index);
        onChange(next);
        break;
      case _ItemAction.moveLeft:
        if (index > 0) {
          final next = List<String>.from(names);
          final tmp = next[index - 1];
          next[index - 1] = next[index];
          next[index] = tmp;
          onChange(next);
        }
        break;
      case _ItemAction.moveRight:
        if (index < names.length - 1) {
          final next = List<String>.from(names);
          final tmp = next[index + 1];
          next[index + 1] = next[index];
          next[index] = tmp;
          onChange(next);
        }
        break;
      case _ItemAction.view:
        openImageViewer(context, service, names, index);
        break;
    }
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }
}

enum _AddSource { gallery, camera, paste }
enum _ItemAction { delete, moveLeft, moveRight, view }

class _Thumb extends ConsumerWidget {
  const _Thumb({
    required this.name,
    required this.position,
    required this.onTap,
    required this.onLongPress,
  });

  final String name;
  final int position;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(imageServiceProvider);
    final file = service.resolveSync(name);
    final exists = file.existsSync();
    final teal = Theme.of(context).colorScheme.secondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 72,
                child: exists
                    ? Image.file(
                        file,
                        fit: BoxFit.cover,
                        cacheWidth: 200,
                        gaplessPlayback: true,
                      )
                    : Container(
                        color: Colors.white.withValues(alpha: 0.05),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white.withValues(alpha: 0.4),
                          size: 26,
                        ),
                      ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: teal.withValues(alpha: 0.7),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '$position',
                  style: TextStyle(
                    color: teal,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final teal = Theme.of(context).colorScheme.secondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Icon(
            Icons.add_a_photo_outlined,
            color: teal,
            size: 26,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../theme/surface_colors.dart';
import '../utils/app_snackbar.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/glass_card.dart';
import '../widgets/tag_chip.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archived = ref.watch(archivedNotesProvider)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(
        leading: BackButton(),
        title: Text('Archive'),
      ),
      body: SafeArea(
        top: false,
        child: archived.isEmpty
            ? const _Empty()
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.only(
                      top: kToolbarHeight +
                          MediaQuery.of(context).padding.top +
                          12,
                    ),
                    sliver: const SliverToBoxAdapter(),
                  ),
                  _ArchiveGrid(notes: archived),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
      ),
    );
  }
}

class _ArchiveGrid extends ConsumerWidget {
  const _ArchiveGrid({required this.notes});
  final List<Note> notes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final cols = width < 600 ? 2 : (width < 960 ? 3 : 4);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: cols,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return _ArchivedCard(
            note: note,
            onRestore: () => _restore(context, ref, note),
            onDeleteForever: () => _confirmDelete(context, ref, note),
          );
        },
      ),
    );
  }

  Future<void> _restore(
      BuildContext context, WidgetRef ref, Note note) async {
    await ref.read(noteServiceProvider).restoreNote(note);
    if (!context.mounted) return;
    showAppSnack(context, 'Restored "${note.title.isEmpty ? 'Untitled' : note.title}"');
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete forever?'),
        content: const Text(
            'This note will be permanently removed from all devices. Cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(noteServiceProvider).forceDeleteNote(note.id);
    if (!context.mounted) return;
    showAppSnack(context, 'Deleted forever');
  }
}

class _ArchivedCard extends StatelessWidget {
  const _ArchivedCard({
    required this.note,
    required this.onRestore,
    required this.onDeleteForever,
  });

  final Note note;
  final VoidCallback onRestore;
  final VoidCallback onDeleteForever;

  @override
  Widget build(BuildContext context) {
    final secondary = onSurfaceMuted(context, 0.6);
    final raw = note.content.trim();

    return GlassCard(
      onTap: onRestore,
      onLongPress: () => _showActions(context),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  note.title.isEmpty ? 'Untitled' : note.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (raw.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              raw,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: onSurfaceMuted(context, 0.7),
              ),
            ),
          ],
          if (note.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final t in note.tags.take(3))
                  TagChip(label: t, dense: true),
                if (note.tags.length > 3)
                  Text(
                    '+${note.tags.length - 3}',
                    style: TextStyle(
                      color: secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat.MMMd().format(note.updatedAt.toDate()),
                style: TextStyle(color: secondary, fontSize: 10),
              ),
              Text(
                'tap to restore',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
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
                  leading: Icon(
                    Icons.unarchive_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: const Text('Restore'),
                  onTap: () {
                    Navigator.pop(ctx);
                    onRestore();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever,
                      color: Colors.redAccent),
                  title: const Text('Delete forever',
                      style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(ctx);
                    onDeleteForever();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: kToolbarHeight + MediaQuery.of(context).padding.top,
        left: 32,
        right: 32,
        bottom: 32,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.archive_outlined,
                size: 52, color: onSurfaceMuted(context, 0.25)),
            const SizedBox(height: 16),
            Text(
              'No archived notes.\nArchived notes appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onSurfaceMuted(context, 0.55),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

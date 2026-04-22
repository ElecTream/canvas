import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../models/note.dart';
import '../providers/image_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/orphan_cleanup_provider.dart';
import '../providers/tags_provider.dart';
import '../services/image_service.dart';
import '../utils/page_routes.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_fab.dart';
import '../widgets/tag_chip.dart';
import 'note_editor_screen.dart';
import 'settings_screen.dart';

enum NoteSort { updated, created, title }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';
  NoteSort _sort = NoteSort.updated;
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _enterSearch() => setState(() => _searching = true);

  void _exitSearch() {
    setState(() {
      _searching = false;
      _searchController.clear();
      _query = '';
    });
  }

  List<Note> _apply(List<Note> notes) {
    final q = _query.trim().toLowerCase();
    Iterable<Note> result = notes;

    if (_selectedTag != null) {
      result = result.where((n) => n.tags.contains(_selectedTag));
    }
    if (q.isNotEmpty) {
      result = result.where((n) =>
          n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q) ||
          n.tags.any((t) => t.toLowerCase().contains(q)));
    }

    final list = result.toList();
    switch (_sort) {
      case NoteSort.updated:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSort.created:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case NoteSort.title:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
    return list;
  }

  void _openEditor([Note? note]) {
    Navigator.push(
      context,
      glassOverlayRoute<void>((_) => NoteEditorScreen(note: note)),
    );
  }

  void _showNoteActions(Note note) {
    final noteService = ref.read(noteServiceProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NoteActionsSheet(
        note: note,
        onTogglePin: () {
          Navigator.pop(ctx);
          noteService.saveNote(note.copyWith(isPinned: !note.isPinned));
        },
        onDelete: () {
          Navigator.pop(ctx);
          noteService.deleteNote(note.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Note deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => noteService.saveNote(note),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesStreamProvider);
    final allTags = ref.watch(tagsProvider);
    ref.watch(orphanCleanupProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: notesAsync.when(
          data: (notes) {
            final filtered = _apply(notes);
            final pinned = filtered.where((n) => n.isPinned).toList();
            final regular = filtered.where((n) => !n.isPinned).toList();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
                  ),
                  sliver: const SliverToBoxAdapter(),
                ),
                if (allTags.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _TagFilterBar(
                      tags: allTags.toList()..sort(),
                      selected: _selectedTag,
                      onSelect: (t) => setState(() => _selectedTag = t),
                    ),
                  ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(query: _query, tag: _selectedTag),
                  )
                else ...[
                  if (pinned.isNotEmpty) ...[
                    const SliverToBoxAdapter(child: _SectionLabel('Pinned')),
                    _NoteGrid(notes: pinned, onTap: _openEditor, onLongPress: _showNoteActions),
                  ],
                  if (regular.isNotEmpty) ...[
                    if (pinned.isNotEmpty)
                      const SliverToBoxAdapter(child: _SectionLabel('Notes')),
                    _NoteGrid(notes: regular, onTap: _openEditor, onLongPress: _showNoteActions),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text('Error: $err', style: const TextStyle(color: Colors.white70)),
          ),
        ),
      ),
      floatingActionButton: GlassFab(
        onPressed: () => _openEditor(),
        icon: Icons.add,
        tooltip: 'New note',
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final sortButton = PopupMenuButton<NoteSort>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort',
      onSelected: (v) => setState(() => _sort = v),
      itemBuilder: (_) => const [
        PopupMenuItem(value: NoteSort.updated, child: Text('Last updated')),
        PopupMenuItem(value: NoteSort.created, child: Text('Date created')),
        PopupMenuItem(value: NoteSort.title, child: Text('Title (A–Z)')),
      ],
    );

    if (_searching) {
      return GlassAppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSearch,
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: const InputDecoration(
            hintText: 'Search notes, tags…',
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
          ),
        ),
        actions: [sortButton],
      );
    }

    return GlassAppBar(
      title: const Text('Canvas'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search',
          onPressed: _enterSearch,
        ),
        sortButton,
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () => Navigator.push(
            context,
            fadeScaleRoute((_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }
}

class _TagFilterBar extends StatelessWidget {
  const _TagFilterBar({
    required this.tags,
    required this.selected,
    required this.onSelect,
  });

  final List<String> tags;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          _AllChip(selected: selected == null, onTap: () => onSelect(null)),
          const SizedBox(width: 6),
          for (final t in tags) ...[
            TagChip(
              label: t,
              selected: selected == t,
              onTap: () => onSelect(selected == t ? null : t),
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _AllChip extends StatelessWidget {
  const _AllChip({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final teal = Theme.of(context).colorScheme.secondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected
                ? teal.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.07),
            border: Border.all(
              color: selected
                  ? teal.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.12),
              width: 0.8,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            'All',
            style: TextStyle(
              color: selected ? teal : Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteGrid extends StatelessWidget {
  const _NoteGrid({
    required this.notes,
    required this.onTap,
    required this.onLongPress,
  });

  final List<Note> notes;
  final ValueChanged<Note> onTap;
  final ValueChanged<Note> onLongPress;

  @override
  Widget build(BuildContext context) {
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
          return AnimationConfiguration.staggeredGrid(
            position: index,
            columnCount: cols,
            duration: const Duration(milliseconds: 350),
            child: ScaleAnimation(
              scale: 0.96,
              child: FadeInAnimation(
                child: _NoteCard(
                  note: note,
                  onTap: () => onTap(note),
                  onLongPress: () => onLongPress(note),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onLongPress,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final raw = note.content.trim();
    final secondary = Colors.white.withValues(alpha: 0.6);
    final teal = Theme.of(context).colorScheme.secondary;
    final hasInlineImages = note.blocks.any((b) => b is ImageBlock);

    return Hero(
      tag: 'note-${note.id}',
      child: GlassCard(
        onTap: onTap,
        onLongPress: onLongPress,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
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
                if (note.isPinned)
                  Padding(
                    padding: const EdgeInsets.only(left: 6, top: 2),
                    child: Icon(Icons.push_pin, size: 14, color: teal),
                  ),
              ],
            ),
            if (hasInlineImages) ...[
              const SizedBox(height: 8),
              IgnorePointer(
                child: _BlockPreview(blocks: note.blocks, accent: teal),
              ),
            ] else if (raw.isNotEmpty) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: ClipRect(
                  child: IgnorePointer(
                    child: _CardMarkdown(data: raw, accent: teal),
                  ),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        '+${note.tags.length - 3}',
                        style: TextStyle(
                          color: secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Text(
              DateFormat.MMMd().format(note.updatedAt.toDate()),
              style: TextStyle(color: secondary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockPreview extends StatelessWidget {
  const _BlockPreview({required this.blocks, required this.accent});
  final List<NoteBlock> blocks;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    double estimated = 0;
    const budget = 220.0;

    for (final b in blocks) {
      if (estimated >= budget) break;
      if (b is TextBlock) {
        final text = b.text.trim();
        if (text.isEmpty) continue;
        children.add(_CardMarkdown(data: text, accent: accent));
        estimated += 70;
      } else if (b is ImageBlock) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _HeroThumb(name: b.name),
              ),
            ),
          ),
        );
        estimated += 120;
      }
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: budget),
      child: ClipRect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query, required this.tag});
  final String query;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final q = query.trim();
    String message;
    IconData icon;
    if (q.isNotEmpty) {
      message = "No notes match '$q'";
      icon = Icons.search_off;
    } else if (tag != null) {
      message = "No notes tagged #$tag";
      icon = Icons.label_off_outlined;
    } else {
      message = 'No notes yet.\nTap + to create one.';
      icon = Icons.edit_note;
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 52, color: Colors.white.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteActionsSheet extends StatelessWidget {
  const _NoteActionsSheet({
    required this.note,
    required this.onTogglePin,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(note.isPinned ? 'Unpin' : 'Pin to top'),
                onTap: onTogglePin,
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardMarkdown extends StatelessWidget {
  const _CardMarkdown({required this.data, required this.accent});
  final String data;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final body = Colors.white.withValues(alpha: 0.8);
    final config = MarkdownConfig.darkConfig.copy(
      configs: [
        PConfig(textStyle: TextStyle(fontSize: 12.5, height: 1.4, color: body)),
        H1Config(
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, height: 1.25),
        ),
        H2Config(
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, height: 1.25),
        ),
        H3Config(
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, height: 1.25),
        ),
        H4Config(
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        H5Config(
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        H6Config(
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        LinkConfig(style: TextStyle(color: accent, decoration: TextDecoration.underline, fontSize: 12.5)),
        CodeConfig(
          style: TextStyle(
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            color: accent,
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
        PreConfig.darkConfig.copy(
          textStyle: TextStyle(color: body, fontSize: 11.5, fontFamily: 'monospace', height: 1.35),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
        ),
        BlockquoteConfig(sideColor: accent, textColor: body),
      ],
    );

    return MarkdownBlock(
      data: data,
      selectable: false,
      config: config,
      generator: MarkdownGenerator(
        linesMargin: const EdgeInsets.symmetric(vertical: 3),
      ),
    );
  }
}

class _HeroThumb extends ConsumerStatefulWidget {
  const _HeroThumb({required this.name});
  final String name;

  @override
  ConsumerState<_HeroThumb> createState() => _HeroThumbState();
}

class _HeroThumbState extends ConsumerState<_HeroThumb> {
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    final service = ref.read(imageServiceProvider);
    final f = service.resolveSync(widget.name);
    if (f.existsSync()) {
      precacheImage(FileImage(f), context).ignore();
    }
    _precached = true;
  }

  @override
  Widget build(BuildContext context) {
    final ImageService service = ref.watch(imageServiceProvider);
    final f = service.resolveSync(widget.name);
    if (!f.existsSync()) {
      return Container(
        color: Colors.white.withValues(alpha: 0.04),
        alignment: Alignment.center,
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.white.withValues(alpha: 0.3),
          size: 32,
        ),
      );
    }
    return Image.file(
      f,
      fit: BoxFit.cover,
      cacheWidth: 600,
      gaplessPlayback: true,
    );
  }
}

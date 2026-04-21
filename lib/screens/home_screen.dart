import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/notes_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _enterSearch() {
    setState(() {
      _searching = true;
    });
  }

  void _exitSearch() {
    setState(() {
      _searching = false;
      _searchController.clear();
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final notesAsyncValue = ref.watch(notesStreamProvider);
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final secondaryTextColor =
        theme.colorScheme.onSurface.withValues(alpha: 0.6);

    final sortButton = PopupMenuButton<NoteSort>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort',
      onSelected: (value) {
        setState(() {
          _sort = value;
        });
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: NoteSort.updated,
          child: Text('Last updated'),
        ),
        PopupMenuItem(
          value: NoteSort.created,
          child: Text('Date created'),
        ),
        PopupMenuItem(
          value: NoteSort.title,
          child: Text('Title (A-Z)'),
        ),
      ],
    );

    final AppBar appBar = _searching
        ? AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close search',
              onPressed: _exitSearch,
            ),
            title: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
              ),
            ),
            actions: [sortButton],
          )
        : AppBar(
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          );

    return Scaffold(
      appBar: appBar,
      body: notesAsyncValue.when(
        data: (notes) {
          final query = _query.trim().toLowerCase();
          final filtered = query.isEmpty
              ? List.of(notes)
              : notes.where((n) {
                  return n.title.toLowerCase().contains(query) ||
                      n.content.toLowerCase().contains(query);
                }).toList();

          switch (_sort) {
            case NoteSort.updated:
              filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
              break;
            case NoteSort.created:
              filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              break;
            case NoteSort.title:
              filtered.sort((a, b) =>
                  a.title.toLowerCase().compareTo(b.title.toLowerCase()));
              break;
          }

          if (filtered.isEmpty) {
            final message = query.isEmpty
                ? 'No notes yet.\nTap the + button to create one!'
                : "No notes match '$_query'";
            return Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: secondaryTextColor, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final note = filtered[index];
              final contentPreview = note.content.replaceAll('\n', ' ').trim();
              const previewLength = 80;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    note.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    contentPreview.length > previewLength
                        ? '${contentPreview.substring(0, previewLength)}...'
                        : contentPreview,
                    style: TextStyle(color: onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    DateFormat.yMMMd().format(note.updatedAt.toDate()),
                    style: TextStyle(color: secondaryTextColor, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteEditorScreen(note: note),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

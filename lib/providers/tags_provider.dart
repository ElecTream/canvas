import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notes_provider.dart';

final tagsProvider = Provider<Set<String>>((ref) {
  final notes = ref.watch(notesStreamProvider).valueOrNull ?? const [];
  return notes.expand((n) => n.tags).toSet();
});

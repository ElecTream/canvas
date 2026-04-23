import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notes_provider.dart';

// Tags are derived, not first-class: the union of tags on the active notes.
// Sourcing from active-only keeps the home filter bar consistent with the
// home grid (which hides archived). Removing the last note carrying a tag
// causes that tag to drop out of the filter bar — there is no standalone
// tag registry. If that ever needs to change, introduce a drift TagRows
// table with explicit lifecycle (rename, color, keep-empty).
final tagsProvider = Provider<Set<String>>((ref) {
  final notes = ref.watch(activeNotesProvider);
  return notes.expand((n) => n.tags).toSet();
});

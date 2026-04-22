import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import 'image_provider.dart';
import 'notes_provider.dart';

final orphanCleanupProvider = Provider<void>((ref) {
  var didRun = false;
  ref.listen<AsyncValue<List<Note>>>(
    notesStreamProvider,
    (prev, next) async {
      if (didRun) return;
      final notes = next.value;
      if (notes == null) return;
      didRun = true;
      final keep = <String>{};
      for (final n in notes) {
        keep.addAll(n.attachments);
      }
      try {
        await ref.read(imageServiceProvider).cleanOrphans(keep);
      } catch (_) {}
    },
    fireImmediately: true,
  );
});

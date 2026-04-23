import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db_provider.dart';
import '../sync/debounced_sync_scheduler.dart';
import '../sync/drift_note_store.dart';
import '../sync/sync_service.dart';
import 'auth_provider.dart';
import 'image_provider.dart';

final _driftStoreProvider = Provider<DriftNoteStore>((ref) {
  return DriftNoteStore(
    ref.watch(notesDaoProvider),
    ref.watch(imagesDaoProvider),
  );
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final svc = SyncService(
    auth: ref.watch(authServiceProvider),
    store: ref.watch(_driftStoreProvider),
    dao: ref.watch(notesDaoProvider),
    imagesDao: ref.watch(imagesDaoProvider),
    imageService: ref.watch(imageServiceProvider),
  );
  ref.onDispose(svc.dispose);
  return svc;
});

final debouncedSyncProvider = Provider<DebouncedSyncScheduler>((ref) {
  final scheduler =
      DebouncedSyncScheduler(ref.watch(syncServiceProvider));
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  final svc = ref.watch(syncServiceProvider);
  yield svc.status;
  yield* svc.statusStream;
});

/// On-demand Drive usage lookup. Recomputes each time it's invalidated so
/// the settings screen can trigger a refresh after a sync.
final driveUsageProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(syncServiceProvider).fetchUsage();
});

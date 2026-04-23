import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db_provider.dart';
import '../services/auth_service.dart';
import '../services/launch_migrator.dart';
import 'image_provider.dart';
import 'sync_provider.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Current signed-in user (mobile Google, web Google, or desktop loopback),
/// or null when signed out. Seeded with the current value so late-subscribing
/// widgets don't flash "signed out".
final signedInUserProvider =
    StreamProvider<SignedInUser?>((ref) async* {
  final svc = ref.watch(authServiceProvider);
  yield svc.currentUser;
  yield* svc.watchSignedInUser();
});

/// One-shot app boot. Runs [LaunchMigrator], which handles legacy Firestore
/// pull (with pre-migration backup), silent Google restore, and flagging for
/// first-Drive-push. After init, a background pull fires if we have a user
/// so remote edits land without blocking UI.
final initializationProvider = FutureProvider<void>((ref) async {
  final auth = ref.read(authServiceProvider);
  final dao = ref.read(notesDaoProvider);

  final migrator = LaunchMigrator(dao: dao, auth: auth);
  final report = await migrator.run();
  // ignore: avoid_print
  // Debug log retained; harmless in release since print is gated.
  // ignore: unused_local_variable
  final _ = report;

  await ref.read(imageServiceProvider).warmup();

  if (auth.currentUser != null) {
    unawaited(ref.read(syncServiceProvider).backgroundSync());
  }
});

/// Reacts to sign-in transitions: when the user moves from signed-out to
/// signed-in, kick a background sync so the first push (or first pull)
/// happens without requiring a manual button tap. Keep this listener alive
/// for the whole app.
final signInTriggerProvider = Provider<void>((ref) {
  SignedInUser? previous;
  ref.listen<AsyncValue<SignedInUser?>>(signedInUserProvider, (prev, next) {
    final now = next.valueOrNull;
    if (previous == null && now != null) {
      unawaited(ref.read(syncServiceProvider).backgroundSync());
    }
    previous = now;
  }, fireImmediately: true);
});

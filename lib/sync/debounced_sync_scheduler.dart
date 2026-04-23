import 'dart:async';

import 'package:flutter/foundation.dart';

import 'sync_service.dart';

/// Coalesces rapid writes into a single sync. Each [schedule] call resets
/// the timer; the push only fires after [delay] of quiet. Cheap to call
/// from every save.
///
/// Silent when signed-out (no-op); the pull-on-open path handles first-sync
/// after sign-in.
class DebouncedSyncScheduler {
  DebouncedSyncScheduler(
    this._sync, {
    this.delay = const Duration(seconds: 5),
  });

  final SyncService _sync;
  final Duration delay;
  Timer? _timer;

  void schedule() {
    _timer?.cancel();
    _timer = Timer(delay, _run);
  }

  /// Cancel any pending timer and run immediately. Used on app background /
  /// shutdown to flush before we lose the chance.
  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    await _run();
  }

  Future<void> _run() async {
    if (_sync.auth.currentUser == null) return;
    try {
      await _sync.syncNow();
    } catch (e) {
      debugPrint('debounced sync failed: $e');
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

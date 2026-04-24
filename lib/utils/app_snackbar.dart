import 'dart:async';

import 'package:flutter/material.dart';

/// Root-scoped ScaffoldMessenger key wired into MaterialApp so snackbars
/// survive route pushes/pops and are never orphaned when the raising screen
/// unmounts. Direct callers should prefer [showAppSnack] over reaching into
/// this key.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// Safety-net timer that force-dismisses the active snackbar even if the
// framework's own duration fails to fire (e.g. when the hosting scaffold
// unmounts mid-animation during a route pop). Canceled on each new show.
Timer? _activeDismissTimer;

/// Standard snackbar entrypoint. Always dismisses any pending snackbar first
/// so we never stack multiple behind each other, and arms a wall-clock timer
/// so navigation mid-snack cannot leave a stale snackbar glued to the screen.
ScaffoldMessengerState? showAppSnack(
  BuildContext context,
  String message, {
  SnackBarAction? action,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = rootScaffoldMessengerKey.currentState ??
      ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return null;

  _activeDismissTimer?.cancel();
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: action,
    ),
  );
  _activeDismissTimer = Timer(
    duration + const Duration(milliseconds: 400),
    () {
      final m = rootScaffoldMessengerKey.currentState;
      m?.hideCurrentSnackBar();
    },
  );
  return messenger;
}

/// Dismiss any visible snackbar immediately. Call on route changes when the
/// snackbar's context no longer makes sense (e.g. user navigated past the
/// action's target).
void dismissAppSnack() {
  _activeDismissTimer?.cancel();
  _activeDismissTimer = null;
  rootScaffoldMessengerKey.currentState?.clearSnackBars();
}

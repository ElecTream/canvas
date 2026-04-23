import 'package:flutter/material.dart';

/// Root-scoped ScaffoldMessenger key wired into MaterialApp so snackbars
/// survive route pushes/pops and are never orphaned when the raising screen
/// unmounts. Direct callers should prefer [showAppSnack] over reaching into
/// this key.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Standard snackbar entrypoint. Always dismisses any pending snackbar first
/// so we never stack multiple behind each other (which was the root cause of
/// "snackbars never go away"). Default 3s duration.
ScaffoldMessengerState? showAppSnack(
  BuildContext context,
  String message, {
  SnackBarAction? action,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = rootScaffoldMessengerKey.currentState ??
      ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return null;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: action,
    ),
  );
  return messenger;
}

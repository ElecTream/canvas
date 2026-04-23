import 'package:flutter/material.dart';

Route<T> fadeScaleRoute<T>(WidgetBuilder builder, {RouteSettings? settings}) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, anim, secondary) => builder(ctx),
    transitionsBuilder: (ctx, anim, secondary, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Slide-in route that cooperates with home's `secondaryAnimation`.
///
/// Subclassing `MaterialPageRoute` is load-bearing: the default
/// `MaterialRouteTransitionMixin.canTransitionTo` only returns true when
/// the *next* route is another `MaterialRouteTransitionMixin` /
/// `CupertinoRouteTransitionMixin`. A raw `PageRouteBuilder` fails that
/// check, so home (a `MaterialPageRoute`) never parents its
/// `_secondaryAnimation` to it — home's secondary stays pinned at 0 and
/// any slide-aside wiring on home is dead. Extending `MaterialPageRoute`
/// passes the mixin check and home's secondaryAnimation ticks normally.
class _SlideOverlayRoute<T> extends MaterialPageRoute<T> {
  _SlideOverlayRoute({
    required super.builder,
    required this.fromLeft,
    super.settings,
  });

  final bool fromLeft;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 260);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 220);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(fromLeft ? -1 : 1, 0),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }
}

/// Slide in from the left (used for Settings — "lives" on the left of home).
PageRoute<T> slideFromLeftRoute<T>(
  WidgetBuilder builder, {
  RouteSettings? settings,
}) {
  return _SlideOverlayRoute<T>(
    builder: builder,
    fromLeft: true,
    settings: settings,
  );
}

/// Slide in from the right (used for Archive — "lives" on the right of home).
PageRoute<T> slideFromRightRoute<T>(
  WidgetBuilder builder, {
  RouteSettings? settings,
}) {
  return _SlideOverlayRoute<T>(
    builder: builder,
    fromLeft: false,
    settings: settings,
  );
}

/// Like [fadeScaleRoute] but non-opaque: the route underneath keeps painting
/// for the full lifetime of this push, so the shared GlassBackground (from
/// MaterialApp.builder) never "pops" at the end of the Hero flight.
Route<T> glassOverlayRoute<T>(WidgetBuilder builder, {RouteSettings? settings}) {
  return PageRouteBuilder<T>(
    settings: settings,
    opaque: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, anim, secondary) => builder(ctx),
    transitionsBuilder: (ctx, anim, secondary, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

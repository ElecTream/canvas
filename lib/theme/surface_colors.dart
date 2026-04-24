import 'package:flutter/material.dart';

/// Frost tint over current surface. Dark theme → white alpha, light → black alpha.
Color surfaceTint(BuildContext ctx, double alpha) {
  final dark = Theme.of(ctx).brightness == Brightness.dark;
  return (dark ? Colors.white : Colors.black).withValues(alpha: alpha);
}

/// Muted on-surface color (dividers, borders, secondary icons/text).
Color onSurfaceMuted(BuildContext ctx, double alpha) =>
    Theme.of(ctx).colorScheme.onSurface.withValues(alpha: alpha);

/// Readable-card base fill: black on dark, white on light.
Color readableBase(BuildContext ctx) {
  final dark = Theme.of(ctx).brightness == Brightness.dark;
  return dark ? Colors.black : Colors.white;
}

/// Inverse of [surfaceTint] — dark on dark, light on light.
Color inverseSurface(BuildContext ctx, double alpha) {
  final dark = Theme.of(ctx).brightness == Brightness.dark;
  return (dark ? Colors.black : Colors.white).withValues(alpha: alpha);
}

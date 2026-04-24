import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/contrast_provider.dart';
import '../providers/palette_provider.dart';
import '../theme/palettes.dart';
import '../theme/surface_colors.dart';

class GlassCard extends ConsumerWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.borderRadius = 16,
    this.blur = 18,
    this.tint,
    this.readable = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  // Blur sigma. Only applied when `readable` is true — gated so home-grid
  // lists don't pay the N-card blur cost that the perf pass stripped out.
  final double blur;
  final Color? tint;
  final bool readable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radius = BorderRadius.circular(borderRadius);
    final palette = paletteColorsOf(ref.watch(paletteProvider));
    final contrast = ref.watch(contrastProvider).scale;
    final accent = Theme.of(context).colorScheme.secondary;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final blobs = palette.blobsFor(brightness);
    final avg = (blobs[0].computeLuminance() +
            blobs[1].computeLuminance() +
            blobs[2].computeLuminance()) /
        3;
    final t = avg.clamp(0.0, 1.0);

    // Light mode favors white frost across the board: non-readable cards
    // become brighter panes over pastel blobs, readable cards pick up a
    // subtle gray so black text reads without tinting the whole surface.
    final Color base;
    final double alpha;
    if (readable) {
      if (isDark) {
        base = Colors.black;
        alpha = (0.40 + 0.25 * t) * contrast;
      } else {
        // White card so black text reads even when a dark image is sitting
        // behind the editor. Floor at 0.6 so Soft contrast still masks
        // the blobs and any inline imagery.
        base = Colors.white;
        alpha = ((0.78 + 0.12 * t) * contrast).clamp(0.6, 1.0);
      }
    } else {
      if (isDark) {
        base = Colors.white;
        alpha = (0.10 + 0.16 * t) * contrast;
      } else {
        // Light + non-readable: push white opacity up so tiles pop against
        // pastel blobs instead of disappearing into the surface.
        base = Colors.white;
        alpha = (0.35 + 0.25 * t) * contrast;
      }
    }
    final fill = tint ?? base.withValues(alpha: alpha.clamp(0.0, 1.0));

    Widget inner = AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(
          color: accent.withValues(
            alpha: (0.25 * contrast).clamp(0.0, 1.0),
          ),
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: radius,
          splashColor: surfaceTint(context, 0.04),
          highlightColor: surfaceTint(context, 0.02),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );

    if (readable) {
      inner = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: inner,
      );
    }

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: radius,
        child: inner,
      ),
    );
  }
}

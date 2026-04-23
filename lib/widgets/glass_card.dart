import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/palette_provider.dart';
import '../theme/palettes.dart';

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
    this.borderAlpha = 0.10,
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
  final double borderAlpha;
  final bool readable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radius = BorderRadius.circular(borderRadius);
    final palette = paletteColorsOf(ref.watch(paletteProvider));
    final avg = (palette.blob1.computeLuminance() +
            palette.blob2.computeLuminance() +
            palette.blob3.computeLuminance()) /
        3;
    final t = avg.clamp(0.0, 1.0);
    final minA = readable ? 0.40 : 0.10;
    final maxA = readable ? 0.65 : 0.26;
    final alpha = minA + (maxA - minA) * t;
    // Readable cards (the editor) tint dark so white body text stays crisp
    // against the palette blobs; non-readable cards keep the bright frosted
    // look they had before.
    final base = readable ? Colors.black : Colors.white;
    final fill = tint ?? base.withValues(alpha: alpha);

    Widget inner = AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(
          color: Colors.white.withValues(alpha: borderAlpha),
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: radius,
          splashColor: Colors.white.withValues(alpha: 0.04),
          highlightColor: Colors.white.withValues(alpha: 0.02),
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

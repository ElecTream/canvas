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
    this.blur = 12,
    this.tint,
    this.borderAlpha = 0.10,
    this.readable = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
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
    final minA = readable ? 0.14 : 0.06;
    final maxA = readable ? 0.38 : 0.22;
    final alpha = minA + (maxA - minA) * t;
    final fill = tint ?? Colors.white.withValues(alpha: alpha);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: AnimatedContainer(
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
          ),
        ),
      ),
    );
  }
}

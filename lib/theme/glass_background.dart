import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/palette_provider.dart';
import 'palettes.dart';

class GlassBackground extends ConsumerWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(paletteProvider);
    final colors = paletteColorsOf(palette);
    final brightness = Theme.of(context).brightness;
    final blobs = colors.blobsFor(brightness);
    final isDark = brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      color: colors.surfaceFor(brightness),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _Blob(
              color: blobs[0],
              size: 420,
              opacity: isDark ? 0.55 : 0.65,
            ),
          ),
          Positioned(
            bottom: -160,
            right: -120,
            child: _Blob(
              color: blobs[1],
              size: 460,
              opacity: isDark ? 0.45 : 0.55,
            ),
          ),
          Positioned(
            top: 240,
            right: -80,
            child: _Blob(
              color: blobs[2],
              size: 320,
              opacity: isDark ? 0.35 : 0.45,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.color,
    required this.size,
    required this.opacity,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

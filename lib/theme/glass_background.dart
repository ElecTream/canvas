import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_theme.dart';

class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceDeep,
      child: Stack(
        children: [
          const Positioned(
            top: -120,
            left: -80,
            child: _Blob(
              color: AppTheme.surfaceBlob1,
              size: 420,
              opacity: 0.55,
            ),
          ),
          const Positioned(
            bottom: -160,
            right: -120,
            child: _Blob(
              color: AppTheme.surfaceBlob2,
              size: 460,
              opacity: 0.45,
            ),
          ),
          const Positioned(
            top: 240,
            right: -80,
            child: _Blob(
              color: AppTheme.midnight,
              size: 320,
              opacity: 0.35,
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
      child: Container(
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

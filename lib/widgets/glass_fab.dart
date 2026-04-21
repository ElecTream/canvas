import 'dart:ui';
import 'package:flutter/material.dart';

class GlassFab extends StatelessWidget {
  const GlassFab({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final teal = Theme.of(context).colorScheme.secondary;

    return RepaintBoundary(
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  teal.withValues(alpha: 0.55),
                  teal.withValues(alpha: 0.25),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: teal.withValues(alpha: 0.35),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: Tooltip(
                  message: tooltip ?? '',
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

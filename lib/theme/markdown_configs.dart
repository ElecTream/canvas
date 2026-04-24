import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'surface_colors.dart';

MarkdownConfig _base(BuildContext ctx) {
  final isDark = Theme.of(ctx).brightness == Brightness.dark;
  return isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;
}

Color _preBg(BuildContext ctx) {
  final isDark = Theme.of(ctx).brightness == Brightness.dark;
  return Colors.black.withValues(alpha: isDark ? 0.28 : 0.06);
}

/// Markdown rendered inside home-screen card previews (small).
MarkdownConfig cardMarkdownConfig(BuildContext ctx, Color accent) {
  final onSurface = Theme.of(ctx).colorScheme.onSurface;
  final body = onSurface.withValues(alpha: 0.8);
  return _base(ctx).copy(configs: [
    PConfig(textStyle: TextStyle(fontSize: 12.5, height: 1.4, color: body)),
    H1Config(
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: onSurface, height: 1.25),
    ),
    H2Config(
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: onSurface, height: 1.25),
    ),
    H3Config(
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: onSurface, height: 1.25),
    ),
    H4Config(
      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: onSurface),
    ),
    H5Config(
      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: onSurface),
    ),
    H6Config(
      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: onSurface),
    ),
    LinkConfig(style: TextStyle(color: accent, decoration: TextDecoration.underline, fontSize: 12.5)),
    CodeConfig(
      style: TextStyle(
        backgroundColor: surfaceTint(ctx, 0.08),
        color: accent,
        fontFamily: 'monospace',
        fontSize: 12,
      ),
    ),
    PreConfig(
      textStyle: TextStyle(color: body, fontSize: 11.5, fontFamily: 'monospace', height: 1.35),
      decoration: BoxDecoration(
        color: _preBg(ctx),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
    ),
    BlockquoteConfig(sideColor: accent, textColor: body),
  ]);
}

/// Markdown rendered in note editor preview mode (full size).
MarkdownConfig editorMarkdownConfig(BuildContext ctx, Color accent) {
  final onSurface = Theme.of(ctx).colorScheme.onSurface;
  final body = onSurface.withValues(alpha: 0.88);
  return _base(ctx).copy(configs: [
    PConfig(textStyle: TextStyle(fontSize: 15, height: 1.55, color: body)),
    H1Config(
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: onSurface, height: 1.3),
    ),
    H2Config(
      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: onSurface, height: 1.3),
    ),
    H3Config(
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: onSurface, height: 1.3),
    ),
    LinkConfig(
      style: TextStyle(color: accent, decoration: TextDecoration.underline, fontSize: 15),
    ),
    CodeConfig(
      style: TextStyle(
        backgroundColor: surfaceTint(ctx, 0.08),
        color: accent,
        fontFamily: 'monospace',
        fontSize: 14,
      ),
    ),
    PreConfig(
      textStyle: TextStyle(color: body, fontSize: 13, fontFamily: 'monospace', height: 1.4),
      decoration: BoxDecoration(
        color: _preBg(ctx),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(10),
    ),
    BlockquoteConfig(sideColor: accent, textColor: body),
  ]);
}

/// Markdown rendered inside the markdown reference modal (example boxes).
MarkdownConfig guideMarkdownConfig(BuildContext ctx, Color accent) {
  final onSurface = Theme.of(ctx).colorScheme.onSurface;
  return _base(ctx).copy(configs: [
    PConfig(
      textStyle: TextStyle(fontSize: 14, height: 1.45, color: onSurface),
    ),
    H1Config(
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: onSurface),
    ),
    H2Config(
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: onSurface),
    ),
    H3Config(
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: onSurface),
    ),
    LinkConfig(
      style: TextStyle(color: accent, decoration: TextDecoration.underline),
    ),
    CodeConfig(
      style: TextStyle(
        backgroundColor: surfaceTint(ctx, 0.08),
        color: accent,
        fontFamily: 'monospace',
        fontSize: 12.5,
      ),
    ),
    PreConfig(
      decoration: BoxDecoration(
        color: _preBg(ctx),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(10),
      textStyle: TextStyle(
        fontFamily: 'monospace',
        fontSize: 12.5,
        color: onSurface,
      ),
    ),
    BlockquoteConfig(
      sideColor: accent,
      textColor: onSurface.withValues(alpha: 0.85),
    ),
  ]);
}

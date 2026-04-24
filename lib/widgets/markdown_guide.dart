import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../theme/markdown_configs.dart';
import '../theme/surface_colors.dart';
import 'glass_card.dart';

void showMarkdownGuide(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => const _MarkdownGuideSheet(),
  );
}

class _MarkdownGuideSheet extends StatelessWidget {
  const _MarkdownGuideSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      maxChildSize: 0.94,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: GlassCard(
          padding: const EdgeInsets.fromLTRB(20, 14, 14, 16),
          readable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Markdown reference',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                'GitHub Flavored Markdown',
                style: TextStyle(
                  color: onSurfaceMuted(ctx, 0.55),
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: onSurfaceMuted(ctx, 0.08), height: 1),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.only(top: 14, bottom: 8, right: 6),
                  children: [
                    const _GuideSection('Inline'),
                    for (final e in _inline) _GuideEntry(e),
                    const SizedBox(height: 16),
                    const _GuideSection('Blocks'),
                    for (final e in _blocks) _GuideEntry(e),
                    const SizedBox(height: 16),
                    const _GuideSection('Advanced'),
                    for (final e in _advanced) _GuideEntry(e),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Entry {
  const _Entry(this.label, this.syntax, this.sample);
  final String label;
  final String syntax;
  final String sample;
}

const _inline = [
  _Entry('Bold', '**text**', '**bold text**'),
  _Entry('Italic', '*text*', '*italic text*'),
  _Entry('Strikethrough', '~~text~~', '~~struck out~~'),
  _Entry('Inline code', '`code`', 'run `flutter pub get`'),
  _Entry('Link', '[label](url)', '[Canvas](https://example.com)'),
];

const _blocks = [
  _Entry('Heading 1', '# Title', '# Heading 1'),
  _Entry('Heading 2', '## Title', '## Heading 2'),
  _Entry('Heading 3', '### Title', '### Heading 3'),
  _Entry('Unordered list', '- item', '- apples\n- pears\n- figs'),
  _Entry('Ordered list', '1. item', '1. first\n2. second\n3. third'),
  _Entry('Blockquote', '> quote', '> Small is beautiful.'),
  _Entry('Horizontal rule', '---', 'above\n\n---\n\nbelow'),
];

const _advanced = [
  _Entry(
    'Fenced code',
    '```lang\ncode\n```',
    '```dart\nvoid main() => print("hi");\n```',
  ),
  _Entry(
    'Table',
    '| a | b |\n|---|---|\n| 1 | 2 |',
    '| key | value |\n|-----|-------|\n| id  | 42    |\n| ok  | true  |',
  ),
];

class _GuideSection extends StatelessWidget {
  const _GuideSection(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: onSurfaceMuted(context, 0.5),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _GuideEntry extends StatelessWidget {
  const _GuideEntry(this.entry);
  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final teal = Theme.of(context).colorScheme.secondary;
    final config = guideMarkdownConfig(context, teal);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  entry.syntax,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: surfaceTint(context, 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: surfaceTint(context, 0.06),
                width: 0.6,
              ),
            ),
            child: MarkdownBlock(
              data: entry.sample,
              selectable: false,
              config: config,
              generator: MarkdownGenerator(
                linesMargin: const EdgeInsets.symmetric(vertical: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

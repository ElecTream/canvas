import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tags_provider.dart';
import '../theme/surface_colors.dart';
import 'tag_chip.dart';

class TagChipInput extends ConsumerStatefulWidget {
  const TagChipInput({
    super.key,
    required this.tags,
    required this.onChanged,
  });

  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  @override
  ConsumerState<TagChipInput> createState() => _TagChipInputState();
}

class _TagChipInputState extends ConsumerState<TagChipInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _inputOpen = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _open() {
    setState(() => _inputOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  void _commit(String raw) {
    final tag = raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
    if (tag.isEmpty) return;
    if (widget.tags.contains(tag)) {
      _controller.clear();
      return;
    }
    widget.onChanged([...widget.tags, tag]);
    _controller.clear();
  }

  void _remove(String tag) {
    widget.onChanged(widget.tags.where((t) => t != tag).toList());
  }

  void _close() {
    setState(() {
      _inputOpen = false;
      _controller.clear();
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final allTags = ref.watch(tagsProvider);
    final query = _controller.text.trim().toLowerCase();
    final suggestions = allTags
        .where((t) => !widget.tags.contains(t) && (query.isEmpty || t.contains(query)))
        .take(6)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final t in widget.tags)
              TagChip(label: t, onDeleted: () => _remove(t)),
            if (!_inputOpen)
              _AddButton(onTap: _open)
            else
              _InlineField(
                controller: _controller,
                focusNode: _focusNode,
                onSubmitted: _commit,
                onClose: _close,
              ),
          ],
        ),
        if (_inputOpen && suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in suggestions)
                TagChip(
                  label: s,
                  dense: true,
                  onTap: () {
                    _commit(s);
                    _focusNode.requestFocus();
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: surfaceTint(context, 0.04),
            border: Border.all(
              color: onSurfaceMuted(context, 0.15),
              width: 0.8,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 14, color: onSurfaceMuted(context, 0.7)),
              const SizedBox(width: 4),
              Text(
                'Tag',
                style: TextStyle(
                  color: onSurfaceMuted(context, 0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineField extends StatefulWidget {
  const _InlineField({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onClose,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClose;

  @override
  State<_InlineField> createState() => _InlineFieldState();
}

class _InlineFieldState extends State<_InlineField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: surfaceTint(context, 0.06),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
                hintText: 'new-tag',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: onSurfaceMuted(context, 0.38),
                ),
              ),
              onSubmitted: widget.onSubmitted,
            ),
          ),
          InkWell(
            onTap: widget.onClose,
            borderRadius: BorderRadius.circular(20),
            child: Icon(
              Icons.close,
              size: 14,
              color: onSurfaceMuted(context, 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

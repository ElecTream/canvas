import 'package:flutter/material.dart';
import '../theme/surface_colors.dart';

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.onTap,
    this.onDeleted,
    this.selected = false,
    this.dense = false,
  });

  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool selected;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected
        ? scheme.secondary.withValues(alpha: 0.22)
        : surfaceTint(context, 0.07);
    final borderColor = selected
        ? scheme.secondary.withValues(alpha: 0.55)
        : onSurfaceMuted(context, 0.12);
    final textColor = selected
        ? scheme.secondary
        : onSurfaceMuted(context, 0.85);

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$label',
            style: TextStyle(
              color: textColor,
              fontSize: dense ? 11 : 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onDeleted,
              borderRadius: BorderRadius.circular(20),
              child: Icon(
                Icons.close,
                size: dense ? 12 : 14,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: content,
        ),
      ),
    );
  }
}

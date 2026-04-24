import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/surface_colors.dart';

const double _kAccentBorderAlpha = 0.25;

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.bottom,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceTint(context, 0.04),
            border: Border(
              bottom: BorderSide(
                color: accent.withValues(alpha: _kAccentBorderAlpha),
                width: 0.6,
              ),
            ),
          ),
          child: AppBar(
            title: title,
            leading: leading,
            actions: actions,
            automaticallyImplyLeading: automaticallyImplyLeading,
            bottom: bottom,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),
      ),
    );
  }
}

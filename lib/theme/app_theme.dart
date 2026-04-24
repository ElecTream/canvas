import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'palettes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData build(PaletteColors colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.seed,
      brightness: brightness,
      surface: colors.surfaceFor(brightness),
    ).copyWith(
      secondary: colors.accent,
      tertiary: colors.accent,
    );

    final baseText = GoogleFonts.latoTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    final overlay = _mix(
      colors.surfaceFor(brightness),
      isDark ? Colors.white : Colors.black,
      0.06,
    );
    final onSurface = colorScheme.onSurface;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      textTheme: baseText,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: onSurface.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: overlay.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: overlay.withValues(alpha: 0.95),
        contentTextStyle: GoogleFonts.lato(color: onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: overlay.withValues(alpha: 0.98),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: onSurface.withValues(alpha: 0.08),
        thickness: 0.5,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: onSurface.withValues(alpha: 0.08),
        side: BorderSide(color: onSurface.withValues(alpha: 0.12)),
        labelStyle: GoogleFonts.lato(
          color: onSurface.withValues(alpha: 0.9),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FadeScalePageTransitions(),
          TargetPlatform.iOS: _FadeScalePageTransitions(),
          TargetPlatform.windows: _FadeScalePageTransitions(),
          TargetPlatform.macOS: _FadeScalePageTransitions(),
          TargetPlatform.linux: _FadeScalePageTransitions(),
        },
      ),
    );
  }
}

Color _mix(Color a, Color b, double t) {
  return Color.lerp(a, b, t)!;
}

class _FadeScalePageTransitions extends PageTransitionsBuilder {
  const _FadeScalePageTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
        child: child,
      ),
    );
  }
}

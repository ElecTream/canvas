import 'package:flutter/material.dart';

enum AccentPalette {
  midnightTeal,
  sageLavender,
  plumGold,
  forestAmber,
  slateRose,
  oceanIce,
  copperIvory,
  magentaCyan,
  charcoalLime,
  obsidianEmber,
}

class PaletteColors {
  const PaletteColors({
    required this.seed,
    required this.accent,
    required this.surface,
    required this.blob1,
    required this.blob2,
    required this.blob3,
    required this.surfaceLight,
    required this.blob1Light,
    required this.blob2Light,
    required this.blob3Light,
    required this.label,
  });

  final Color seed;
  final Color accent;
  final Color surface;
  final Color blob1;
  final Color blob2;
  final Color blob3;
  final Color surfaceLight;
  final Color blob1Light;
  final Color blob2Light;
  final Color blob3Light;
  final String label;

  Color surfaceFor(Brightness b) =>
      b == Brightness.dark ? surface : surfaceLight;

  List<Color> blobsFor(Brightness b) => b == Brightness.dark
      ? [blob1, blob2, blob3]
      : [blob1Light, blob2Light, blob3Light];
}

const Map<AccentPalette, PaletteColors> palettes = {
  AccentPalette.midnightTeal: PaletteColors(
    seed: Color(0xFF1E3A8A),
    accent: Color(0xFF2DD4BF),
    surface: Color(0xFF0B1020),
    blob1: Color(0xFF1E40AF),
    blob2: Color(0xFF0D9488),
    blob3: Color(0xFF1E3A8A),
    surfaceLight: Color(0xFFF3F6FC),
    blob1Light: Color(0xFFC7D4F0),
    blob2Light: Color(0xFFB9E5DD),
    blob3Light: Color(0xFFD4DCF3),
    label: 'Midnight · Teal',
  ),
  AccentPalette.sageLavender: PaletteColors(
    seed: Color(0xFF4F7942),
    accent: Color(0xFFB4A7D6),
    surface: Color(0xFF0E1411),
    blob1: Color(0xFF5D8850),
    blob2: Color(0xFF9A8CC4),
    blob3: Color(0xFF2D3A2A),
    surfaceLight: Color(0xFFF4F7F2),
    blob1Light: Color(0xFFCFE0C7),
    blob2Light: Color(0xFFDCD4EF),
    blob3Light: Color(0xFFD7DFD2),
    label: 'Sage · Lavender',
  ),
  AccentPalette.plumGold: PaletteColors(
    seed: Color(0xFF6B21A8),
    accent: Color(0xFFFBBF24),
    surface: Color(0xFF14091F),
    blob1: Color(0xFF7C3AED),
    blob2: Color(0xFFB45309),
    blob3: Color(0xFF4C1D95),
    surfaceLight: Color(0xFFF8F3FB),
    blob1Light: Color(0xFFDDCDF5),
    blob2Light: Color(0xFFF5D9AE),
    blob3Light: Color(0xFFD9CDED),
    label: 'Plum · Gold',
  ),
  AccentPalette.forestAmber: PaletteColors(
    seed: Color(0xFF166534),
    accent: Color(0xFFF59E0B),
    surface: Color(0xFF0A1410),
    blob1: Color(0xFF15803D),
    blob2: Color(0xFFB45309),
    blob3: Color(0xFF064E3B),
    surfaceLight: Color(0xFFF1F7F3),
    blob1Light: Color(0xFFBCE0C8),
    blob2Light: Color(0xFFF5D9AE),
    blob3Light: Color(0xFFB9DCCA),
    label: 'Forest · Amber',
  ),
  AccentPalette.slateRose: PaletteColors(
    seed: Color(0xFF475569),
    accent: Color(0xFFFB7185),
    surface: Color(0xFF0F1419),
    blob1: Color(0xFF334155),
    blob2: Color(0xFFBE185D),
    blob3: Color(0xFF1E293B),
    surfaceLight: Color(0xFFF3F5F8),
    blob1Light: Color(0xFFCDD4DD),
    blob2Light: Color(0xFFF3CADA),
    blob3Light: Color(0xFFCED5DF),
    label: 'Slate · Rose',
  ),
  AccentPalette.oceanIce: PaletteColors(
    seed: Color(0xFF1E40AF),
    accent: Color(0xFF67E8F9),
    surface: Color(0xFF061423),
    blob1: Color(0xFF1D4ED8),
    blob2: Color(0xFF0891B2),
    blob3: Color(0xFF172554),
    surfaceLight: Color(0xFFF0F6FC),
    blob1Light: Color(0xFFC6D6F4),
    blob2Light: Color(0xFFBDE0EA),
    blob3Light: Color(0xFFCCD3EA),
    label: 'Ocean · Ice',
  ),
  AccentPalette.copperIvory: PaletteColors(
    seed: Color(0xFFB87333),
    accent: Color(0xFFFFF0D9),
    surface: Color(0xFF1A1208),
    blob1: Color(0xFF9C5A23),
    blob2: Color(0xFFD4A574),
    blob3: Color(0xFF2E1B0A),
    surfaceLight: Color(0xFFFAF6EF),
    blob1Light: Color(0xFFE8D2B8),
    blob2Light: Color(0xFFF1E0C5),
    blob3Light: Color(0xFFE1D2BE),
    label: 'Copper · Ivory',
  ),
  AccentPalette.magentaCyan: PaletteColors(
    seed: Color(0xFFC026D3),
    accent: Color(0xFF06B6D4),
    surface: Color(0xFF0E0818),
    blob1: Color(0xFFA21CAF),
    blob2: Color(0xFF0891B2),
    blob3: Color(0xFF3B0764),
    surfaceLight: Color(0xFFF7F2FA),
    blob1Light: Color(0xFFE8C6EE),
    blob2Light: Color(0xFFB9E0EA),
    blob3Light: Color(0xFFD3C5E5),
    label: 'Magenta · Cyan',
  ),
  AccentPalette.charcoalLime: PaletteColors(
    seed: Color(0xFF27272A),
    accent: Color(0xFF84CC16),
    surface: Color(0xFF09090B),
    blob1: Color(0xFF3F3F46),
    blob2: Color(0xFF65A30D),
    blob3: Color(0xFF18181B),
    surfaceLight: Color(0xFFF4F4F5),
    blob1Light: Color(0xFFD4D4D8),
    blob2Light: Color(0xFFCDE3A5),
    blob3Light: Color(0xFFD9D9DC),
    label: 'Charcoal · Lime',
  ),
  AccentPalette.obsidianEmber: PaletteColors(
    seed: Color(0xFF18181B),
    accent: Color(0xFFF97316),
    surface: Color(0xFF0A0A0C),
    blob1: Color(0xFF27272A),
    blob2: Color(0xFFC2410C),
    blob3: Color(0xFF18181B),
    surfaceLight: Color(0xFFF5F5F5),
    blob1Light: Color(0xFFD6D6D9),
    blob2Light: Color(0xFFF4CCB4),
    blob3Light: Color(0xFFDADADD),
    label: 'Obsidian · Ember',
  ),
};

PaletteColors paletteColorsOf(AccentPalette p) => palettes[p]!;

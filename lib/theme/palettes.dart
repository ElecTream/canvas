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
    required this.label,
  });

  final Color seed;
  final Color accent;
  final Color surface;
  final Color blob1;
  final Color blob2;
  final Color blob3;
  final String label;
}

const Map<AccentPalette, PaletteColors> palettes = {
  AccentPalette.midnightTeal: PaletteColors(
    seed: Color(0xFF1E3A8A),
    accent: Color(0xFF2DD4BF),
    surface: Color(0xFF0B1020),
    blob1: Color(0xFF1E40AF),
    blob2: Color(0xFF0D9488),
    blob3: Color(0xFF1E3A8A),
    label: 'Midnight · Teal',
  ),
  AccentPalette.sageLavender: PaletteColors(
    seed: Color(0xFF4F7942),
    accent: Color(0xFFB4A7D6),
    surface: Color(0xFF0E1411),
    blob1: Color(0xFF5D8850),
    blob2: Color(0xFF9A8CC4),
    blob3: Color(0xFF2D3A2A),
    label: 'Sage · Lavender',
  ),
  AccentPalette.plumGold: PaletteColors(
    seed: Color(0xFF6B21A8),
    accent: Color(0xFFFBBF24),
    surface: Color(0xFF14091F),
    blob1: Color(0xFF7C3AED),
    blob2: Color(0xFFB45309),
    blob3: Color(0xFF4C1D95),
    label: 'Plum · Gold',
  ),
  AccentPalette.forestAmber: PaletteColors(
    seed: Color(0xFF166534),
    accent: Color(0xFFF59E0B),
    surface: Color(0xFF0A1410),
    blob1: Color(0xFF15803D),
    blob2: Color(0xFFB45309),
    blob3: Color(0xFF064E3B),
    label: 'Forest · Amber',
  ),
  AccentPalette.slateRose: PaletteColors(
    seed: Color(0xFF475569),
    accent: Color(0xFFFB7185),
    surface: Color(0xFF0F1419),
    blob1: Color(0xFF334155),
    blob2: Color(0xFFBE185D),
    blob3: Color(0xFF1E293B),
    label: 'Slate · Rose',
  ),
  AccentPalette.oceanIce: PaletteColors(
    seed: Color(0xFF1E40AF),
    accent: Color(0xFF67E8F9),
    surface: Color(0xFF061423),
    blob1: Color(0xFF1D4ED8),
    blob2: Color(0xFF0891B2),
    blob3: Color(0xFF172554),
    label: 'Ocean · Ice',
  ),
  AccentPalette.copperIvory: PaletteColors(
    seed: Color(0xFFB87333),
    accent: Color(0xFFFFF0D9),
    surface: Color(0xFF1A1208),
    blob1: Color(0xFF9C5A23),
    blob2: Color(0xFFD4A574),
    blob3: Color(0xFF2E1B0A),
    label: 'Copper · Ivory',
  ),
  AccentPalette.magentaCyan: PaletteColors(
    seed: Color(0xFFC026D3),
    accent: Color(0xFF06B6D4),
    surface: Color(0xFF0E0818),
    blob1: Color(0xFFA21CAF),
    blob2: Color(0xFF0891B2),
    blob3: Color(0xFF3B0764),
    label: 'Magenta · Cyan',
  ),
  AccentPalette.charcoalLime: PaletteColors(
    seed: Color(0xFF27272A),
    accent: Color(0xFF84CC16),
    surface: Color(0xFF09090B),
    blob1: Color(0xFF3F3F46),
    blob2: Color(0xFF65A30D),
    blob3: Color(0xFF18181B),
    label: 'Charcoal · Lime',
  ),
  AccentPalette.obsidianEmber: PaletteColors(
    seed: Color(0xFF18181B),
    accent: Color(0xFFF97316),
    surface: Color(0xFF0A0A0C),
    blob1: Color(0xFF27272A),
    blob2: Color(0xFFC2410C),
    blob3: Color(0xFF18181B),
    label: 'Obsidian · Ember',
  ),
};

PaletteColors paletteColorsOf(AccentPalette p) => palettes[p]!;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/palettes.dart';

class PaletteNotifier extends StateNotifier<AccentPalette> {
  PaletteNotifier() : super(AccentPalette.midnightTeal) {
    _load();
  }

  static const _key = 'accent_palette';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key);
    if (name == null) return;
    for (final p in AccentPalette.values) {
      if (p.name == name) {
        state = p;
        return;
      }
    }
  }

  Future<void> set(AccentPalette p) async {
    state = p;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, p.name);
  }
}

final paletteProvider =
    StateNotifierProvider<PaletteNotifier, AccentPalette>(
  (ref) => PaletteNotifier(),
);

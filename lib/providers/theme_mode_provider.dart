import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  static const _key = 'theme_mode';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key);
    if (name == null) return;
    for (final m in ThemeMode.values) {
      if (m.name == name) {
        state = m;
        return;
      }
    }
  }

  Future<void> set(ThemeMode m) async {
    state = m;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, m.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

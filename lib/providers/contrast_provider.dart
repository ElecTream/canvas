import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ContrastLevel { soft, standard, bold }

extension ContrastLevelX on ContrastLevel {
  /// Multiplier applied to glass-card alphas. >1 = more opaque, <1 = softer.
  double get scale => switch (this) {
        ContrastLevel.soft => 0.7,
        ContrastLevel.standard => 1.0,
        ContrastLevel.bold => 1.5,
      };

  String get label => switch (this) {
        ContrastLevel.soft => 'Soft',
        ContrastLevel.standard => 'Standard',
        ContrastLevel.bold => 'Bold',
      };
}

class ContrastNotifier extends StateNotifier<ContrastLevel> {
  ContrastNotifier() : super(ContrastLevel.standard) {
    _load();
  }

  static const _key = 'contrast_level';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key);
    if (name == null) return;
    for (final l in ContrastLevel.values) {
      if (l.name == name) {
        state = l;
        return;
      }
    }
  }

  Future<void> set(ContrastLevel l) async {
    state = l;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, l.name);
  }
}

final contrastProvider =
    StateNotifierProvider<ContrastNotifier, ContrastLevel>(
  (ref) => ContrastNotifier(),
);

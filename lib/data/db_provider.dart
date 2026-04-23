import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_db.dart';
import 'images_dao.dart';
import 'notes_dao.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final notesDaoProvider = Provider<NotesDao>((ref) {
  return NotesDao(ref.watch(appDatabaseProvider));
});

final imagesDaoProvider = Provider<ImagesDao>((ref) {
  return ImagesDao(ref.watch(appDatabaseProvider));
});

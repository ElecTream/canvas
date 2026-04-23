import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_db.g.dart';

class NoteRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  // JSON-encoded List<Map>.
  TextColumn get blocksJson => text().withDefault(const Constant('[]'))();
  // JSON-encoded List<String>.
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get attachmentsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isPinned =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  // Sync bookkeeping (used by Phase 3+).
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get remoteRev => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tombstones extends Table {
  TextColumn get id => text()();
  DateTimeColumn get deletedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tracks local image blobs. `filename` is the UUID-based local name used in
/// `note.attachments`. `sha256` is the Drive-side blob ID (content-addressed
/// for dedupe across notes + devices). `uploadedAt` is null until the blob
/// has been pushed to Drive.
class ImageBlobs extends Table {
  TextColumn get filename => text()();
  TextColumn get sha256 => text()();
  IntColumn get sizeBytes => integer()();
  DateTimeColumn get uploadedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {filename};
}

class SyncStateRows extends Table {
  // Singleton row keyed on id = 0.
  IntColumn get id => integer()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  BoolColumn get importedFromFirestore =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get firstDrivePushComplete =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get legacyBackupWrittenAt => dateTime().nullable()();
  TextColumn get legacyBackupPath => text().nullable()();
  // Throttle for the remote-orphan reconciliation pass; see sync_service.
  DateTimeColumn get lastOrphanScanAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [NoteRows, Tombstones, SyncStateRows, ImageBlobs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(
                syncStateRows, syncStateRows.firstDrivePushComplete);
            await m.addColumn(
                syncStateRows, syncStateRows.legacyBackupWrittenAt);
            await m.addColumn(
                syncStateRows, syncStateRows.legacyBackupPath);
          }
          if (from < 3) {
            await m.createTable(imageBlobs);
          }
          if (from < 4) {
            await m.addColumn(noteRows, noteRows.isArchived);
          }
          if (from < 5) {
            await m.addColumn(
                syncStateRows, syncStateRows.lastOrphanScanAt);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'canvas.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

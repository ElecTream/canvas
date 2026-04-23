import 'package:drift/drift.dart';

import 'app_db.dart';

part 'images_dao.g.dart';

@DriftAccessor(tables: [ImageBlobs])
class ImagesDao extends DatabaseAccessor<AppDatabase> with _$ImagesDaoMixin {
  ImagesDao(super.db);

  Future<void> record({
    required String filename,
    required String sha256,
    required int sizeBytes,
  }) async {
    await into(imageBlobs).insertOnConflictUpdate(
      ImageBlobsCompanion.insert(
        filename: filename,
        sha256: sha256,
        sizeBytes: sizeBytes,
      ),
    );
  }

  Future<ImageBlob?> getByFilename(String filename) =>
      (select(imageBlobs)..where((t) => t.filename.equals(filename)))
          .getSingleOrNull();

  Future<List<ImageBlob>> getUnuploaded() =>
      (select(imageBlobs)..where((t) => t.uploadedAt.isNull())).get();

  Future<List<ImageBlob>> getAll() => select(imageBlobs).get();

  Future<void> markUploaded(String filename, DateTime at) async {
    await (update(imageBlobs)..where((t) => t.filename.equals(filename)))
        .write(ImageBlobsCompanion(uploadedAt: Value(at)));
  }

  Future<void> deleteByFilename(String filename) async {
    await (delete(imageBlobs)..where((t) => t.filename.equals(filename))).go();
  }

  /// Returns `sha256` indexed by `filename` for a set of filenames.
  Future<Map<String, String>> shasFor(Iterable<String> filenames) async {
    if (filenames.isEmpty) return const {};
    final rows = await (select(imageBlobs)
          ..where((t) => t.filename.isIn(filenames.toList())))
        .get();
    return {for (final r in rows) r.filename: r.sha256};
  }
}

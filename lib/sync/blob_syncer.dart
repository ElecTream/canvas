import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../data/images_dao.dart';
import '../data/notes_dao.dart';
import '../services/image_service.dart';
import 'drive_adapter.dart';

/// Pushes unuploaded local blobs before a record sync, then pulls any blobs
/// referenced by notes that aren't present on disk afterward.
///
/// Failures are logged but swallowed so one broken blob doesn't crash the
/// entire sync. Engine still completes; next run re-tries.
class BlobSyncer {
  BlobSyncer({
    required this.imagesDao,
    required this.notesDao,
    required this.imageService,
    required this.adapter,
  });

  final ImagesDao imagesDao;
  final NotesDao notesDao;
  final ImageService imageService;
  final DriveAdapter adapter;

  /// Push every local blob whose `uploadedAt` is null. Call before the note
  /// push so remote notes reference blobs that already exist.
  Future<BlobSyncReport> pushMissing() async {
    final report = BlobSyncReport();
    final pending = await imagesDao.getUnuploaded();
    for (final row in pending) {
      try {
        final f = imageService.resolveSync(row.filename);
        if (!await f.exists()) {
          report.skippedMissingLocal++;
          continue;
        }
        final bytes = await f.readAsBytes();
        final ext = _extOf(row.filename);
        await adapter.pushBlob(bytes, '${row.sha256}$ext');
        await imagesDao.markUploaded(row.filename, DateTime.now().toUtc());
        report.pushed++;
      } catch (e) {
        debugPrint('BlobSyncer.pushMissing ${row.filename}: $e');
        report.errors++;
      }
    }
    return report;
  }

  /// Pulls blobs referenced by any active note but not present locally.
  /// The pull-record pass persists filename↔sha mappings into the images
  /// table via [NoteSyncRecord.extractAttachmentShas]; we honor those here.
  Future<BlobSyncReport> pullMissing() async {
    final report = BlobSyncReport();
    final notes = await notesDao.getAllNotes();
    final referenced = <String>{
      for (final n in notes) ...n.attachments,
    };
    if (referenced.isEmpty) return report;

    for (final filename in referenced) {
      try {
        final f = imageService.resolveSync(filename);
        if (await f.exists()) continue;
        final row = await imagesDao.getByFilename(filename);
        if (row == null) {
          report.skippedMissingSha++;
          continue;
        }
        final ext = _extOf(filename);
        final bytes = await adapter.fetchBlob('${row.sha256}$ext');
        await imageService.ingestFromRemote(
          filename: filename,
          sha256: row.sha256,
          bytes: bytes,
        );
        report.pulled++;
      } catch (e) {
        debugPrint('BlobSyncer.pullMissing $filename: $e');
        report.errors++;
      }
    }
    return report;
  }

  String _extOf(String filename) {
    final e = p.extension(filename);
    return e.isEmpty ? '' : e;
  }
}

class BlobSyncReport {
  int pushed = 0;
  int pulled = 0;
  int skippedMissingLocal = 0;
  int skippedMissingSha = 0;
  int errors = 0;

  @override
  String toString() =>
      'BlobSyncReport(pushed: $pushed, pulled: $pulled, '
      'skippedMissingLocal: $skippedMissingLocal, '
      'skippedMissingSha: $skippedMissingSha, errors: $errors)';
}

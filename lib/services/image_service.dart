import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:uuid/uuid.dart';

import '../data/images_dao.dart';

class ImageService extends ChangeNotifier {
  ImageService(this._imagesDao);

  static const int maxEdgePx = 2048;
  static const int quality = 85;

  final ImagesDao _imagesDao;
  final ImagePicker _picker = ImagePicker();
  Directory? _cachedDir;

  // Per-filename edit counter. Bumped on overwriteBytes so display widgets
  // can key their `Image.file` by `img-$name-$rev` and dodge the stale frame
  // that `gaplessPlayback: true` otherwise pins on the stream.
  final Map<String, int> _revisions = {};
  int revisionFor(String name) => _revisions[name] ?? 0;
  void _bumpRevision(String name) {
    _revisions[name] = (_revisions[name] ?? 0) + 1;
    notifyListeners();
  }

  Future<Directory> dir() async {
    if (_cachedDir != null) return _cachedDir!;
    final base = await getApplicationDocumentsDirectory();
    final d = Directory(p.join(base.path, 'images'));
    if (!await d.exists()) await d.create(recursive: true);
    _cachedDir = d;
    return d;
  }

  Future<File> resolve(String name) async =>
      File(p.join((await dir()).path, name));

  /// Pre-warm [_cachedDir] so [resolveSync] / [pathFor] never trip.
  Future<void> warmup() async {
    await dir();
  }

  /// Synchronous path lookup. Requires [warmup] (or any prior [dir] call) first.
  String pathFor(String name) {
    final d = _cachedDir;
    if (d == null) {
      throw StateError(
        'ImageService.pathFor called before warmup(); await warmup() at boot.',
      );
    }
    return p.join(d.path, name);
  }

  /// Synchronous file handle. Same warmup requirement as [pathFor].
  File resolveSync(String name) => File(pathFor(name));

  Future<Uint8List> compress(Uint8List bytes) async {
    return FlutterImageCompress.compressWithList(
      bytes,
      minWidth: maxEdgePx,
      minHeight: maxEdgePx,
      quality: quality,
      format: CompressFormat.jpeg,
    );
  }

  Future<String> saveBytes(Uint8List raw) async {
    final compressed = await compress(raw);
    final name = '${const Uuid().v4()}.jpg';
    final f = File(p.join((await dir()).path, name));
    await f.writeAsBytes(compressed, flush: true);
    await _recordBlob(name, compressed);
    return name;
  }

  Future<void> _recordBlob(String filename, Uint8List bytes) async {
    final sha = crypto.sha256.convert(bytes).toString();
    await _imagesDao.record(
      filename: filename,
      sha256: sha,
      sizeBytes: bytes.length,
    );
  }

  /// Ingest a blob fetched from Drive. Writes the file to disk if missing
  /// and records its SHA so pull-completions don't trigger spurious re-pushes.
  Future<void> ingestFromRemote({
    required String filename,
    required String sha256,
    required Uint8List bytes,
  }) async {
    final f = File(p.join((await dir()).path, filename));
    if (!await f.exists()) {
      await f.writeAsBytes(bytes, flush: true);
    }
    await _imagesDao.record(
      filename: filename,
      sha256: sha256,
      sizeBytes: bytes.length,
    );
    await _imagesDao.markUploaded(filename, DateTime.now().toUtc());
  }

  Future<String> saveFile(File src) async =>
      saveBytes(await src.readAsBytes());

  Future<String> saveXFile(XFile x) async =>
      saveBytes(await x.readAsBytes());

  /// Overwrite an existing file in-place. Used for crop/rotate/resize so all
  /// inline placements of the same attachment pick up the edit on next paint.
  Future<void> overwriteBytes(String name, Uint8List raw) async {
    final compressed = await compress(raw);
    final f = File(pathFor(name));
    await f.writeAsBytes(compressed, flush: true);
    // Content changed → recompute hash, reset uploaded flag so the next sync
    // pushes the new blob to Drive.
    await _recordBlob(name, compressed);
    _evictAllForFile(f);
    _bumpRevision(name);
  }

  // `Image.file(..., cacheWidth: ...)` wraps FileImage in a ResizeImage whose
  // cache key we can't reach by hand — evict the raw FileImage, then clear
  // live + cold entries so the next paint re-reads the bytes off disk.
  void _evictAllForFile(File f) {
    final cache = PaintingBinding.instance.imageCache;
    cache.evict(FileImage(f));
    cache.clear();
    cache.clearLiveImages();
  }

  Future<XFile?> pickGallery() {
    return _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 4096,
      maxHeight: 4096,
      imageQuality: 100,
    );
  }

  Future<List<XFile>> pickGalleryMulti() {
    return _picker.pickMultiImage(
      maxWidth: 4096,
      maxHeight: 4096,
      imageQuality: 100,
    );
  }

  Future<XFile?> pickCamera() {
    return _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 4096,
      maxHeight: 4096,
      imageQuality: 100,
    );
  }

  Future<Uint8List?> readClipboardImage() async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) return null;
    final reader = await clipboard.read();
    FileFormat? format;
    if (reader.canProvide(Formats.png)) {
      format = Formats.png;
    } else if (reader.canProvide(Formats.jpeg)) {
      format = Formats.jpeg;
    } else if (reader.canProvide(Formats.webp)) {
      format = Formats.webp;
    } else if (reader.canProvide(Formats.gif)) {
      format = Formats.gif;
    }
    if (format == null) return null;

    final completer = Completer<Uint8List?>();
    reader.getFile(
      format,
      (file) async {
        try {
          final bytes = await file.readAll();
          if (!completer.isCompleted) completer.complete(bytes);
        } catch (_) {
          if (!completer.isCompleted) completer.complete(null);
        }
      },
      onError: (_) {
        if (!completer.isCompleted) completer.complete(null);
      },
    );
    return completer.future;
  }

  Future<void> delete(String name) async {
    final f = await resolve(name);
    if (await f.exists()) await f.delete();
    await _imagesDao.deleteByFilename(name);
  }

  Future<int> cleanOrphans(Set<String> keep) async {
    final d = await dir();
    int removed = 0;
    await for (final e in d.list()) {
      if (e is File) {
        final name = p.basename(e.path);
        if (!keep.contains(name)) {
          try {
            await e.delete();
            await _imagesDao.deleteByFilename(name);
            removed++;
          } catch (_) {}
        }
      }
    }
    return removed;
  }
}

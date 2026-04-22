import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  static const int maxEdgePx = 2048;
  static const int quality = 85;

  final ImagePicker _picker = ImagePicker();
  Directory? _cachedDir;

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
    return name;
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
    PaintingBinding.instance.imageCache.evict(FileImage(f));
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
            removed++;
          } catch (_) {}
        }
      }
    }
    return removed;
  }
}

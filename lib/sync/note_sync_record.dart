import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:local_sync/local_sync.dart';

import '../models/note.dart';

/// Syncable view over a [Note]. Serializes timestamps as ISO-8601 so Drive
/// files are portable and human-inspectable; Firestore's `Timestamp` is an
/// internal artifact we'll drop in Phase 6.
///
/// Attachments are enriched with SHA-256s at push time so consumers on other
/// devices can locate the matching blob in `/canvas/blobs/<sha>.<ext>`.
/// On pull the enriched form is collapsed back to a bare `List<String>` of
/// filenames — the SHA-side of the round-trip is stashed by the caller in
/// the `images` drift table before the note is written locally.
class NoteSyncRecord implements Syncable {
  final Note note;

  /// Optional map of attachment filename → sha256. Used only at push time
  /// when serializing to Drive; irrelevant for fromJson.
  final Map<String, String> attachmentShas;

  NoteSyncRecord(this.note, {this.attachmentShas = const {}});

  @override
  String get id => note.id;

  @override
  DateTime get updatedAt => note.updatedAt.toDate().toUtc();

  @override
  Map<String, dynamic> toJson() => {
        'id': note.id,
        'title': note.title,
        'content': note.content,
        'blocks': note.blocks.map((b) => b.toJson()).toList(),
        'tags': note.tags,
        'attachments': note.attachments
            .map((name) => {
                  'filename': name,
                  if (attachmentShas[name] != null)
                    'sha256': attachmentShas[name],
                })
            .toList(),
        'isPinned': note.isPinned,
        'isArchived': note.isArchived,
        'createdAt': note.createdAt.toDate().toUtc().toIso8601String(),
        'updatedAt': note.updatedAt.toDate().toUtc().toIso8601String(),
      };

  /// Pulls just the attachment-filename → sha256 mapping out of a remote
  /// JSON document so the caller can record it in the images table before
  /// constructing a plain [Note].
  static Map<String, String> extractAttachmentShas(Map<String, dynamic> json) {
    final raw = json['attachments'];
    if (raw is! List) return const {};
    final out = <String, String>{};
    for (final e in raw) {
      if (e is Map) {
        final f = e['filename'];
        final s = e['sha256'];
        if (f is String && s is String) out[f] = s;
      }
    }
    return out;
  }

  static NoteSyncRecord fromJson(Map<String, dynamic> json) {
    final shas = extractAttachmentShas(json);
    final rawCreated = json['createdAt'];
    final rawUpdated = json['updatedAt'];
    final bridged = Map<String, dynamic>.from(json);
    if (rawCreated is String) {
      bridged['createdAt'] = Timestamp.fromDate(DateTime.parse(rawCreated));
    }
    if (rawUpdated is String) {
      bridged['updatedAt'] = Timestamp.fromDate(DateTime.parse(rawUpdated));
    }
    // Collapse attachment maps back to bare filenames for the domain Note.
    final rawAttachments = bridged['attachments'];
    if (rawAttachments is List) {
      bridged['attachments'] = rawAttachments
          .map((e) {
            if (e is String) return e;
            if (e is Map) return e['filename'] as String?;
            return null;
          })
          .whereType<String>()
          .toList();
    }
    return NoteSyncRecord(Note.fromJson(bridged), attachmentShas: shas);
  }
}

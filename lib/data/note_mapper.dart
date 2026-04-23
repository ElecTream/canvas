import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../models/note.dart';
import 'app_db.dart';

/// Bridges the domain `Note` (still Timestamp-based in Phase 1) with the drift
/// row `NoteRow`. Phase 6 will drop the Timestamp side entirely.
class NoteMapper {
  static Note fromRow(NoteRow row) {
    final rawBlocks = jsonDecode(row.blocksJson);
    final rawTags = jsonDecode(row.tagsJson);
    final rawAttachments = jsonDecode(row.attachmentsJson);
    return Note(
      id: row.id,
      title: row.title,
      blocks: _blocksFromJson(rawBlocks, row.content),
      tags: rawTags is List ? rawTags.whereType<String>().toList() : const [],
      attachments: rawAttachments is List
          ? rawAttachments.whereType<String>().toList()
          : const [],
      isPinned: row.isPinned,
      isArchived: row.isArchived,
      createdAt: Timestamp.fromDate(row.createdAt),
      updatedAt: Timestamp.fromDate(row.updatedAt),
    );
  }

  static NoteRowsCompanion toCompanion(
    Note note, {
    required bool dirty,
    DateTime? remoteRev,
  }) {
    return NoteRowsCompanion(
      id: Value(note.id),
      title: Value(note.title),
      content: Value(note.content),
      blocksJson: Value(jsonEncode(note.blocks.map((b) => b.toJson()).toList())),
      tagsJson: Value(jsonEncode(note.tags)),
      attachmentsJson: Value(jsonEncode(note.attachments)),
      isPinned: Value(note.isPinned),
      isArchived: Value(note.isArchived),
      createdAt: Value(note.createdAt.toDate()),
      updatedAt: Value(note.updatedAt.toDate()),
      dirty: Value(dirty),
      remoteRev:
          remoteRev != null ? Value(remoteRev) : const Value.absent(),
    );
  }

  static List<NoteBlock> _blocksFromJson(dynamic raw, String legacyContent) {
    if (raw is List) {
      final out = <NoteBlock>[];
      for (final m in raw) {
        if (m is! Map) continue;
        final type = m['type'];
        if (type == 'text') {
          final t = m['text'];
          out.add(TextBlock(t is String ? t : ''));
        } else if (type == 'image') {
          final n = m['name'];
          if (n is String && n.isNotEmpty) {
            final w = m['width'];
            final nr = m['newRow'];
            out.add(ImageBlock(
              n,
              width: w is num ? w.toDouble().clamp(0.2, 1.0) : 1.0,
              newRow: nr is bool ? nr : false,
            ));
          }
        }
      }
      if (out.isNotEmpty) return out;
    }
    return [TextBlock(legacyContent)];
  }
}

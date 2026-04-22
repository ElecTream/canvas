import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

sealed class NoteBlock {
  const NoteBlock();
  Map<String, dynamic> toJson();
}

class TextBlock extends NoteBlock {
  final String text;
  const TextBlock(this.text);

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};

  @override
  bool operator ==(Object other) =>
      other is TextBlock && other.text == text;

  @override
  int get hashCode => Object.hash('text', text);
}

class ImageBlock extends NoteBlock {
  final String name;
  final double width;
  final bool newRow;
  const ImageBlock(this.name, {this.width = 0.5, this.newRow = false});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'image',
        'name': name,
        'width': width,
        'newRow': newRow,
      };

  @override
  bool operator ==(Object other) =>
      other is ImageBlock &&
      other.name == name &&
      other.width == width &&
      other.newRow == newRow;

  @override
  int get hashCode => Object.hash('image', name, width, newRow);
}

String _flattenBlocks(List<NoteBlock> blocks) => blocks
    .whereType<TextBlock>()
    .map((b) => b.text)
    .where((t) => t.isNotEmpty)
    .join('\n\n');

List<NoteBlock> _blocksFromJson(dynamic raw, String legacyContent) {
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

class Note {
  final String id;
  final String title;
  final String content;
  final List<NoteBlock> blocks;
  final List<String> tags;
  final List<String> attachments;
  final bool isPinned;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Note._({
    required this.id,
    required this.title,
    required this.content,
    required this.blocks,
    required this.tags,
    required this.attachments,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note({
    String? id,
    required String title,
    String? content,
    List<NoteBlock>? blocks,
    List<String>? tags,
    List<String>? attachments,
    bool? isPinned,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    final resolvedBlocks = blocks ?? [TextBlock(content ?? '')];
    final resolvedContent =
        blocks != null ? _flattenBlocks(blocks) : (content ?? '');
    return Note._(
      id: id ?? const Uuid().v4(),
      title: title,
      content: resolvedContent,
      blocks: resolvedBlocks,
      tags: tags ?? const [],
      attachments: attachments ?? const [],
      isPinned: isPinned ?? false,
      createdAt: createdAt ?? Timestamp.now(),
      updatedAt: updatedAt ?? Timestamp.now(),
    );
  }

  Note copyWith({
    String? title,
    String? content,
    List<NoteBlock>? blocks,
    List<String>? tags,
    List<String>? attachments,
    bool? isPinned,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? (blocks == null ? this.content : null),
      blocks: blocks ?? this.blocks,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawTitle = json['title'];
    final rawContent = json['content'];
    final rawBlocks = json['blocks'];
    final rawTags = json['tags'];
    final rawAttachments = json['attachments'];
    final rawIsPinned = json['isPinned'];
    final rawCreatedAt = json['createdAt'];
    final rawUpdatedAt = json['updatedAt'];

    final legacyContent = rawContent is String ? rawContent : '';
    final parsedBlocks = _blocksFromJson(rawBlocks, legacyContent);

    return Note(
      id: rawId is String && rawId.isNotEmpty ? rawId : const Uuid().v4(),
      title: rawTitle is String ? rawTitle : '',
      blocks: parsedBlocks,
      tags: rawTags is List ? rawTags.whereType<String>().toList() : const [],
      attachments: rawAttachments is List
          ? rawAttachments.whereType<String>().toList()
          : const [],
      isPinned: rawIsPinned is bool ? rawIsPinned : false,
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt : Timestamp.now(),
      updatedAt: rawUpdatedAt is Timestamp ? rawUpdatedAt : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'blocks': blocks.map((b) => b.toJson()).toList(),
      'tags': tags,
      'attachments': attachments,
      'isPinned': isPinned,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Note && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Note(id: $id)';
}

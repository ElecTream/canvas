import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final bool isPinned;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Note({
    required this.title,
    required this.content,
    String? id,
    List<String>? tags,
    bool? isPinned,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        tags = tags ?? const [],
        isPinned = isPinned ?? false,
        createdAt = createdAt ?? Timestamp.now(),
        updatedAt = updatedAt ?? Timestamp.now();

  Note copyWith({
    String? title,
    String? content,
    List<String>? tags,
    bool? isPinned,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawTitle = json['title'];
    final rawContent = json['content'];
    final rawTags = json['tags'];
    final rawIsPinned = json['isPinned'];
    final rawCreatedAt = json['createdAt'];
    final rawUpdatedAt = json['updatedAt'];

    return Note(
      id: rawId is String && rawId.isNotEmpty ? rawId : const Uuid().v4(),
      title: rawTitle is String ? rawTitle : '',
      content: rawContent is String ? rawContent : '',
      tags: rawTags is List ? rawTags.whereType<String>().toList() : const [],
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
      'tags': tags,
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

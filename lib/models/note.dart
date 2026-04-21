import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Note({
    required this.title,
    required this.content,
    String? id,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? Timestamp.now(),
        updatedAt = updatedAt ?? Timestamp.now();

  Note copyWith({
    String? title,
    String? content,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawTitle = json['title'];
    final rawContent = json['content'];
    final rawCreatedAt = json['createdAt'];
    final rawUpdatedAt = json['updatedAt'];

    return Note(
      id: rawId is String && rawId.isNotEmpty ? rawId : const Uuid().v4(),
      title: rawTitle is String ? rawTitle : '',
      content: rawContent is String ? rawContent : '',
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt : Timestamp.now(),
      updatedAt: rawUpdatedAt is Timestamp ? rawUpdatedAt : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
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

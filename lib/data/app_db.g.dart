// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $NoteRowsTable extends NoteRows with TableInfo<$NoteRowsTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _blocksJsonMeta =
      const VerificationMeta('blocksJson');
  @override
  late final GeneratedColumn<String> blocksJson = GeneratedColumn<String>(
      'blocks_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _attachmentsJsonMeta =
      const VerificationMeta('attachmentsJson');
  @override
  late final GeneratedColumn<String> attachmentsJson = GeneratedColumn<String>(
      'attachments_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _remoteRevMeta =
      const VerificationMeta('remoteRev');
  @override
  late final GeneratedColumn<DateTime> remoteRev = GeneratedColumn<DateTime>(
      'remote_rev', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        content,
        blocksJson,
        tagsJson,
        attachmentsJson,
        isPinned,
        isArchived,
        createdAt,
        updatedAt,
        dirty,
        remoteRev
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_rows';
  @override
  VerificationContext validateIntegrity(Insertable<NoteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('blocks_json')) {
      context.handle(
          _blocksJsonMeta,
          blocksJson.isAcceptableOrUnknown(
              data['blocks_json']!, _blocksJsonMeta));
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('attachments_json')) {
      context.handle(
          _attachmentsJsonMeta,
          attachmentsJson.isAcceptableOrUnknown(
              data['attachments_json']!, _attachmentsJsonMeta));
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('remote_rev')) {
      context.handle(_remoteRevMeta,
          remoteRev.isAcceptableOrUnknown(data['remote_rev']!, _remoteRevMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      blocksJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}blocks_json'])!,
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json'])!,
      attachmentsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}attachments_json'])!,
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      remoteRev: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}remote_rev']),
    );
  }

  @override
  $NoteRowsTable createAlias(String alias) {
    return $NoteRowsTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final String id;
  final String title;
  final String content;
  final String blocksJson;
  final String tagsJson;
  final String attachmentsJson;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool dirty;
  final DateTime? remoteRev;
  const NoteRow(
      {required this.id,
      required this.title,
      required this.content,
      required this.blocksJson,
      required this.tagsJson,
      required this.attachmentsJson,
      required this.isPinned,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt,
      required this.dirty,
      this.remoteRev});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['blocks_json'] = Variable<String>(blocksJson);
    map['tags_json'] = Variable<String>(tagsJson);
    map['attachments_json'] = Variable<String>(attachmentsJson);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || remoteRev != null) {
      map['remote_rev'] = Variable<DateTime>(remoteRev);
    }
    return map;
  }

  NoteRowsCompanion toCompanion(bool nullToAbsent) {
    return NoteRowsCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
      blocksJson: Value(blocksJson),
      tagsJson: Value(tagsJson),
      attachmentsJson: Value(attachmentsJson),
      isPinned: Value(isPinned),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
      remoteRev: remoteRev == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteRev),
    );
  }

  factory NoteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      blocksJson: serializer.fromJson<String>(json['blocksJson']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      attachmentsJson: serializer.fromJson<String>(json['attachmentsJson']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      remoteRev: serializer.fromJson<DateTime?>(json['remoteRev']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'blocksJson': serializer.toJson<String>(blocksJson),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'attachmentsJson': serializer.toJson<String>(attachmentsJson),
      'isPinned': serializer.toJson<bool>(isPinned),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'remoteRev': serializer.toJson<DateTime?>(remoteRev),
    };
  }

  NoteRow copyWith(
          {String? id,
          String? title,
          String? content,
          String? blocksJson,
          String? tagsJson,
          String? attachmentsJson,
          bool? isPinned,
          bool? isArchived,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? dirty,
          Value<DateTime?> remoteRev = const Value.absent()}) =>
      NoteRow(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        blocksJson: blocksJson ?? this.blocksJson,
        tagsJson: tagsJson ?? this.tagsJson,
        attachmentsJson: attachmentsJson ?? this.attachmentsJson,
        isPinned: isPinned ?? this.isPinned,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        dirty: dirty ?? this.dirty,
        remoteRev: remoteRev.present ? remoteRev.value : this.remoteRev,
      );
  NoteRow copyWithCompanion(NoteRowsCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      blocksJson:
          data.blocksJson.present ? data.blocksJson.value : this.blocksJson,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      attachmentsJson: data.attachmentsJson.present
          ? data.attachmentsJson.value
          : this.attachmentsJson,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      remoteRev: data.remoteRev.present ? data.remoteRev.value : this.remoteRev,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('blocksJson: $blocksJson, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('attachmentsJson: $attachmentsJson, ')
          ..write('isPinned: $isPinned, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteRev: $remoteRev')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      content,
      blocksJson,
      tagsJson,
      attachmentsJson,
      isPinned,
      isArchived,
      createdAt,
      updatedAt,
      dirty,
      remoteRev);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.content == this.content &&
          other.blocksJson == this.blocksJson &&
          other.tagsJson == this.tagsJson &&
          other.attachmentsJson == this.attachmentsJson &&
          other.isPinned == this.isPinned &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.remoteRev == this.remoteRev);
}

class NoteRowsCompanion extends UpdateCompanion<NoteRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> content;
  final Value<String> blocksJson;
  final Value<String> tagsJson;
  final Value<String> attachmentsJson;
  final Value<bool> isPinned;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> dirty;
  final Value<DateTime?> remoteRev;
  final Value<int> rowid;
  const NoteRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.blocksJson = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.attachmentsJson = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteRev = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteRowsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.blocksJson = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.attachmentsJson = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.dirty = const Value.absent(),
    this.remoteRev = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<NoteRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? blocksJson,
    Expression<String>? tagsJson,
    Expression<String>? attachmentsJson,
    Expression<bool>? isPinned,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? dirty,
    Expression<DateTime>? remoteRev,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (blocksJson != null) 'blocks_json': blocksJson,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (attachmentsJson != null) 'attachments_json': attachmentsJson,
      if (isPinned != null) 'is_pinned': isPinned,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (remoteRev != null) 'remote_rev': remoteRev,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? content,
      Value<String>? blocksJson,
      Value<String>? tagsJson,
      Value<String>? attachmentsJson,
      Value<bool>? isPinned,
      Value<bool>? isArchived,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? dirty,
      Value<DateTime?>? remoteRev,
      Value<int>? rowid}) {
    return NoteRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      blocksJson: blocksJson ?? this.blocksJson,
      tagsJson: tagsJson ?? this.tagsJson,
      attachmentsJson: attachmentsJson ?? this.attachmentsJson,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      remoteRev: remoteRev ?? this.remoteRev,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (blocksJson.present) {
      map['blocks_json'] = Variable<String>(blocksJson.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (attachmentsJson.present) {
      map['attachments_json'] = Variable<String>(attachmentsJson.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (remoteRev.present) {
      map['remote_rev'] = Variable<DateTime>(remoteRev.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('blocksJson: $blocksJson, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('attachmentsJson: $attachmentsJson, ')
          ..write('isPinned: $isPinned, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteRev: $remoteRev, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TombstonesTable extends Tombstones
    with TableInfo<$TombstonesTable, Tombstone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TombstonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tombstones';
  @override
  VerificationContext validateIntegrity(Insertable<Tombstone> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    } else if (isInserting) {
      context.missing(_deletedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tombstone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tombstone(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at'])!,
    );
  }

  @override
  $TombstonesTable createAlias(String alias) {
    return $TombstonesTable(attachedDatabase, alias);
  }
}

class Tombstone extends DataClass implements Insertable<Tombstone> {
  final String id;
  final DateTime deletedAt;
  const Tombstone({required this.id, required this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    return map;
  }

  TombstonesCompanion toCompanion(bool nullToAbsent) {
    return TombstonesCompanion(
      id: Value(id),
      deletedAt: Value(deletedAt),
    );
  }

  factory Tombstone.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tombstone(
      id: serializer.fromJson<String>(json['id']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
    };
  }

  Tombstone copyWith({String? id, DateTime? deletedAt}) => Tombstone(
        id: id ?? this.id,
        deletedAt: deletedAt ?? this.deletedAt,
      );
  Tombstone copyWithCompanion(TombstonesCompanion data) {
    return Tombstone(
      id: data.id.present ? data.id.value : this.id,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tombstone(')
          ..write('id: $id, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tombstone &&
          other.id == this.id &&
          other.deletedAt == this.deletedAt);
}

class TombstonesCompanion extends UpdateCompanion<Tombstone> {
  final Value<String> id;
  final Value<DateTime> deletedAt;
  final Value<int> rowid;
  const TombstonesCompanion({
    this.id = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TombstonesCompanion.insert({
    required String id,
    required DateTime deletedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deletedAt = Value(deletedAt);
  static Insertable<Tombstone> custom({
    Expression<String>? id,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TombstonesCompanion copyWith(
      {Value<String>? id, Value<DateTime>? deletedAt, Value<int>? rowid}) {
    return TombstonesCompanion(
      id: id ?? this.id,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TombstonesCompanion(')
          ..write('id: $id, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateRowsTable extends SyncStateRows
    with TableInfo<$SyncStateRowsTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
      'last_sync_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _importedFromFirestoreMeta =
      const VerificationMeta('importedFromFirestore');
  @override
  late final GeneratedColumn<bool> importedFromFirestore =
      GeneratedColumn<bool>('imported_from_firestore', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("imported_from_firestore" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _firstDrivePushCompleteMeta =
      const VerificationMeta('firstDrivePushComplete');
  @override
  late final GeneratedColumn<bool> firstDrivePushComplete =
      GeneratedColumn<bool>('first_drive_push_complete', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("first_drive_push_complete" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _legacyBackupWrittenAtMeta =
      const VerificationMeta('legacyBackupWrittenAt');
  @override
  late final GeneratedColumn<DateTime> legacyBackupWrittenAt =
      GeneratedColumn<DateTime>('legacy_backup_written_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _legacyBackupPathMeta =
      const VerificationMeta('legacyBackupPath');
  @override
  late final GeneratedColumn<String> legacyBackupPath = GeneratedColumn<String>(
      'legacy_backup_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastOrphanScanAtMeta =
      const VerificationMeta('lastOrphanScanAt');
  @override
  late final GeneratedColumn<DateTime> lastOrphanScanAt =
      GeneratedColumn<DateTime>('last_orphan_scan_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        lastSyncAt,
        importedFromFirestore,
        firstDrivePushComplete,
        legacyBackupWrittenAt,
        legacyBackupPath,
        lastOrphanScanAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state_rows';
  @override
  VerificationContext validateIntegrity(Insertable<SyncStateRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    if (data.containsKey('imported_from_firestore')) {
      context.handle(
          _importedFromFirestoreMeta,
          importedFromFirestore.isAcceptableOrUnknown(
              data['imported_from_firestore']!, _importedFromFirestoreMeta));
    }
    if (data.containsKey('first_drive_push_complete')) {
      context.handle(
          _firstDrivePushCompleteMeta,
          firstDrivePushComplete.isAcceptableOrUnknown(
              data['first_drive_push_complete']!, _firstDrivePushCompleteMeta));
    }
    if (data.containsKey('legacy_backup_written_at')) {
      context.handle(
          _legacyBackupWrittenAtMeta,
          legacyBackupWrittenAt.isAcceptableOrUnknown(
              data['legacy_backup_written_at']!, _legacyBackupWrittenAtMeta));
    }
    if (data.containsKey('legacy_backup_path')) {
      context.handle(
          _legacyBackupPathMeta,
          legacyBackupPath.isAcceptableOrUnknown(
              data['legacy_backup_path']!, _legacyBackupPathMeta));
    }
    if (data.containsKey('last_orphan_scan_at')) {
      context.handle(
          _lastOrphanScanAtMeta,
          lastOrphanScanAt.isAcceptableOrUnknown(
              data['last_orphan_scan_at']!, _lastOrphanScanAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync_at']),
      importedFromFirestore: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}imported_from_firestore'])!,
      firstDrivePushComplete: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}first_drive_push_complete'])!,
      legacyBackupWrittenAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}legacy_backup_written_at']),
      legacyBackupPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}legacy_backup_path']),
      lastOrphanScanAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_orphan_scan_at']),
    );
  }

  @override
  $SyncStateRowsTable createAlias(String alias) {
    return $SyncStateRowsTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final int id;
  final DateTime? lastSyncAt;
  final bool importedFromFirestore;
  final bool firstDrivePushComplete;
  final DateTime? legacyBackupWrittenAt;
  final String? legacyBackupPath;
  final DateTime? lastOrphanScanAt;
  const SyncStateRow(
      {required this.id,
      this.lastSyncAt,
      required this.importedFromFirestore,
      required this.firstDrivePushComplete,
      this.legacyBackupWrittenAt,
      this.legacyBackupPath,
      this.lastOrphanScanAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    map['imported_from_firestore'] = Variable<bool>(importedFromFirestore);
    map['first_drive_push_complete'] = Variable<bool>(firstDrivePushComplete);
    if (!nullToAbsent || legacyBackupWrittenAt != null) {
      map['legacy_backup_written_at'] =
          Variable<DateTime>(legacyBackupWrittenAt);
    }
    if (!nullToAbsent || legacyBackupPath != null) {
      map['legacy_backup_path'] = Variable<String>(legacyBackupPath);
    }
    if (!nullToAbsent || lastOrphanScanAt != null) {
      map['last_orphan_scan_at'] = Variable<DateTime>(lastOrphanScanAt);
    }
    return map;
  }

  SyncStateRowsCompanion toCompanion(bool nullToAbsent) {
    return SyncStateRowsCompanion(
      id: Value(id),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      importedFromFirestore: Value(importedFromFirestore),
      firstDrivePushComplete: Value(firstDrivePushComplete),
      legacyBackupWrittenAt: legacyBackupWrittenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyBackupWrittenAt),
      legacyBackupPath: legacyBackupPath == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyBackupPath),
      lastOrphanScanAt: lastOrphanScanAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOrphanScanAt),
    );
  }

  factory SyncStateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      id: serializer.fromJson<int>(json['id']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      importedFromFirestore:
          serializer.fromJson<bool>(json['importedFromFirestore']),
      firstDrivePushComplete:
          serializer.fromJson<bool>(json['firstDrivePushComplete']),
      legacyBackupWrittenAt:
          serializer.fromJson<DateTime?>(json['legacyBackupWrittenAt']),
      legacyBackupPath: serializer.fromJson<String?>(json['legacyBackupPath']),
      lastOrphanScanAt:
          serializer.fromJson<DateTime?>(json['lastOrphanScanAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'importedFromFirestore': serializer.toJson<bool>(importedFromFirestore),
      'firstDrivePushComplete': serializer.toJson<bool>(firstDrivePushComplete),
      'legacyBackupWrittenAt':
          serializer.toJson<DateTime?>(legacyBackupWrittenAt),
      'legacyBackupPath': serializer.toJson<String?>(legacyBackupPath),
      'lastOrphanScanAt': serializer.toJson<DateTime?>(lastOrphanScanAt),
    };
  }

  SyncStateRow copyWith(
          {int? id,
          Value<DateTime?> lastSyncAt = const Value.absent(),
          bool? importedFromFirestore,
          bool? firstDrivePushComplete,
          Value<DateTime?> legacyBackupWrittenAt = const Value.absent(),
          Value<String?> legacyBackupPath = const Value.absent(),
          Value<DateTime?> lastOrphanScanAt = const Value.absent()}) =>
      SyncStateRow(
        id: id ?? this.id,
        lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
        importedFromFirestore:
            importedFromFirestore ?? this.importedFromFirestore,
        firstDrivePushComplete:
            firstDrivePushComplete ?? this.firstDrivePushComplete,
        legacyBackupWrittenAt: legacyBackupWrittenAt.present
            ? legacyBackupWrittenAt.value
            : this.legacyBackupWrittenAt,
        legacyBackupPath: legacyBackupPath.present
            ? legacyBackupPath.value
            : this.legacyBackupPath,
        lastOrphanScanAt: lastOrphanScanAt.present
            ? lastOrphanScanAt.value
            : this.lastOrphanScanAt,
      );
  SyncStateRow copyWithCompanion(SyncStateRowsCompanion data) {
    return SyncStateRow(
      id: data.id.present ? data.id.value : this.id,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
      importedFromFirestore: data.importedFromFirestore.present
          ? data.importedFromFirestore.value
          : this.importedFromFirestore,
      firstDrivePushComplete: data.firstDrivePushComplete.present
          ? data.firstDrivePushComplete.value
          : this.firstDrivePushComplete,
      legacyBackupWrittenAt: data.legacyBackupWrittenAt.present
          ? data.legacyBackupWrittenAt.value
          : this.legacyBackupWrittenAt,
      legacyBackupPath: data.legacyBackupPath.present
          ? data.legacyBackupPath.value
          : this.legacyBackupPath,
      lastOrphanScanAt: data.lastOrphanScanAt.present
          ? data.lastOrphanScanAt.value
          : this.lastOrphanScanAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('id: $id, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('importedFromFirestore: $importedFromFirestore, ')
          ..write('firstDrivePushComplete: $firstDrivePushComplete, ')
          ..write('legacyBackupWrittenAt: $legacyBackupWrittenAt, ')
          ..write('legacyBackupPath: $legacyBackupPath, ')
          ..write('lastOrphanScanAt: $lastOrphanScanAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      lastSyncAt,
      importedFromFirestore,
      firstDrivePushComplete,
      legacyBackupWrittenAt,
      legacyBackupPath,
      lastOrphanScanAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.id == this.id &&
          other.lastSyncAt == this.lastSyncAt &&
          other.importedFromFirestore == this.importedFromFirestore &&
          other.firstDrivePushComplete == this.firstDrivePushComplete &&
          other.legacyBackupWrittenAt == this.legacyBackupWrittenAt &&
          other.legacyBackupPath == this.legacyBackupPath &&
          other.lastOrphanScanAt == this.lastOrphanScanAt);
}

class SyncStateRowsCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<int> id;
  final Value<DateTime?> lastSyncAt;
  final Value<bool> importedFromFirestore;
  final Value<bool> firstDrivePushComplete;
  final Value<DateTime?> legacyBackupWrittenAt;
  final Value<String?> legacyBackupPath;
  final Value<DateTime?> lastOrphanScanAt;
  const SyncStateRowsCompanion({
    this.id = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.importedFromFirestore = const Value.absent(),
    this.firstDrivePushComplete = const Value.absent(),
    this.legacyBackupWrittenAt = const Value.absent(),
    this.legacyBackupPath = const Value.absent(),
    this.lastOrphanScanAt = const Value.absent(),
  });
  SyncStateRowsCompanion.insert({
    this.id = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.importedFromFirestore = const Value.absent(),
    this.firstDrivePushComplete = const Value.absent(),
    this.legacyBackupWrittenAt = const Value.absent(),
    this.legacyBackupPath = const Value.absent(),
    this.lastOrphanScanAt = const Value.absent(),
  });
  static Insertable<SyncStateRow> custom({
    Expression<int>? id,
    Expression<DateTime>? lastSyncAt,
    Expression<bool>? importedFromFirestore,
    Expression<bool>? firstDrivePushComplete,
    Expression<DateTime>? legacyBackupWrittenAt,
    Expression<String>? legacyBackupPath,
    Expression<DateTime>? lastOrphanScanAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (importedFromFirestore != null)
        'imported_from_firestore': importedFromFirestore,
      if (firstDrivePushComplete != null)
        'first_drive_push_complete': firstDrivePushComplete,
      if (legacyBackupWrittenAt != null)
        'legacy_backup_written_at': legacyBackupWrittenAt,
      if (legacyBackupPath != null) 'legacy_backup_path': legacyBackupPath,
      if (lastOrphanScanAt != null) 'last_orphan_scan_at': lastOrphanScanAt,
    });
  }

  SyncStateRowsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? lastSyncAt,
      Value<bool>? importedFromFirestore,
      Value<bool>? firstDrivePushComplete,
      Value<DateTime?>? legacyBackupWrittenAt,
      Value<String?>? legacyBackupPath,
      Value<DateTime?>? lastOrphanScanAt}) {
    return SyncStateRowsCompanion(
      id: id ?? this.id,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      importedFromFirestore:
          importedFromFirestore ?? this.importedFromFirestore,
      firstDrivePushComplete:
          firstDrivePushComplete ?? this.firstDrivePushComplete,
      legacyBackupWrittenAt:
          legacyBackupWrittenAt ?? this.legacyBackupWrittenAt,
      legacyBackupPath: legacyBackupPath ?? this.legacyBackupPath,
      lastOrphanScanAt: lastOrphanScanAt ?? this.lastOrphanScanAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (importedFromFirestore.present) {
      map['imported_from_firestore'] =
          Variable<bool>(importedFromFirestore.value);
    }
    if (firstDrivePushComplete.present) {
      map['first_drive_push_complete'] =
          Variable<bool>(firstDrivePushComplete.value);
    }
    if (legacyBackupWrittenAt.present) {
      map['legacy_backup_written_at'] =
          Variable<DateTime>(legacyBackupWrittenAt.value);
    }
    if (legacyBackupPath.present) {
      map['legacy_backup_path'] = Variable<String>(legacyBackupPath.value);
    }
    if (lastOrphanScanAt.present) {
      map['last_orphan_scan_at'] = Variable<DateTime>(lastOrphanScanAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRowsCompanion(')
          ..write('id: $id, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('importedFromFirestore: $importedFromFirestore, ')
          ..write('firstDrivePushComplete: $firstDrivePushComplete, ')
          ..write('legacyBackupWrittenAt: $legacyBackupWrittenAt, ')
          ..write('legacyBackupPath: $legacyBackupPath, ')
          ..write('lastOrphanScanAt: $lastOrphanScanAt')
          ..write(')'))
        .toString();
  }
}

class $ImageBlobsTable extends ImageBlobs
    with TableInfo<$ImageBlobsTable, ImageBlob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageBlobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _filenameMeta =
      const VerificationMeta('filename');
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
      'filename', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
      'sha256', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _uploadedAtMeta =
      const VerificationMeta('uploadedAt');
  @override
  late final GeneratedColumn<DateTime> uploadedAt = GeneratedColumn<DateTime>(
      'uploaded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [filename, sha256, sizeBytes, uploadedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_blobs';
  @override
  VerificationContext validateIntegrity(Insertable<ImageBlob> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('filename')) {
      context.handle(_filenameMeta,
          filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta));
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(_sha256Meta,
          sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta));
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('uploaded_at')) {
      context.handle(
          _uploadedAtMeta,
          uploadedAt.isAcceptableOrUnknown(
              data['uploaded_at']!, _uploadedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {filename};
  @override
  ImageBlob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageBlob(
      filename: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}filename'])!,
      sha256: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sha256'])!,
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
      uploadedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}uploaded_at']),
    );
  }

  @override
  $ImageBlobsTable createAlias(String alias) {
    return $ImageBlobsTable(attachedDatabase, alias);
  }
}

class ImageBlob extends DataClass implements Insertable<ImageBlob> {
  final String filename;
  final String sha256;
  final int sizeBytes;
  final DateTime? uploadedAt;
  const ImageBlob(
      {required this.filename,
      required this.sha256,
      required this.sizeBytes,
      this.uploadedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['filename'] = Variable<String>(filename);
    map['sha256'] = Variable<String>(sha256);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || uploadedAt != null) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt);
    }
    return map;
  }

  ImageBlobsCompanion toCompanion(bool nullToAbsent) {
    return ImageBlobsCompanion(
      filename: Value(filename),
      sha256: Value(sha256),
      sizeBytes: Value(sizeBytes),
      uploadedAt: uploadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(uploadedAt),
    );
  }

  factory ImageBlob.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageBlob(
      filename: serializer.fromJson<String>(json['filename']),
      sha256: serializer.fromJson<String>(json['sha256']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      uploadedAt: serializer.fromJson<DateTime?>(json['uploadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'filename': serializer.toJson<String>(filename),
      'sha256': serializer.toJson<String>(sha256),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'uploadedAt': serializer.toJson<DateTime?>(uploadedAt),
    };
  }

  ImageBlob copyWith(
          {String? filename,
          String? sha256,
          int? sizeBytes,
          Value<DateTime?> uploadedAt = const Value.absent()}) =>
      ImageBlob(
        filename: filename ?? this.filename,
        sha256: sha256 ?? this.sha256,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        uploadedAt: uploadedAt.present ? uploadedAt.value : this.uploadedAt,
      );
  ImageBlob copyWithCompanion(ImageBlobsCompanion data) {
    return ImageBlob(
      filename: data.filename.present ? data.filename.value : this.filename,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      uploadedAt:
          data.uploadedAt.present ? data.uploadedAt.value : this.uploadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageBlob(')
          ..write('filename: $filename, ')
          ..write('sha256: $sha256, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('uploadedAt: $uploadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(filename, sha256, sizeBytes, uploadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageBlob &&
          other.filename == this.filename &&
          other.sha256 == this.sha256 &&
          other.sizeBytes == this.sizeBytes &&
          other.uploadedAt == this.uploadedAt);
}

class ImageBlobsCompanion extends UpdateCompanion<ImageBlob> {
  final Value<String> filename;
  final Value<String> sha256;
  final Value<int> sizeBytes;
  final Value<DateTime?> uploadedAt;
  final Value<int> rowid;
  const ImageBlobsCompanion({
    this.filename = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageBlobsCompanion.insert({
    required String filename,
    required String sha256,
    required int sizeBytes,
    this.uploadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : filename = Value(filename),
        sha256 = Value(sha256),
        sizeBytes = Value(sizeBytes);
  static Insertable<ImageBlob> custom({
    Expression<String>? filename,
    Expression<String>? sha256,
    Expression<int>? sizeBytes,
    Expression<DateTime>? uploadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (filename != null) 'filename': filename,
      if (sha256 != null) 'sha256': sha256,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (uploadedAt != null) 'uploaded_at': uploadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageBlobsCompanion copyWith(
      {Value<String>? filename,
      Value<String>? sha256,
      Value<int>? sizeBytes,
      Value<DateTime?>? uploadedAt,
      Value<int>? rowid}) {
    return ImageBlobsCompanion(
      filename: filename ?? this.filename,
      sha256: sha256 ?? this.sha256,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (uploadedAt.present) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageBlobsCompanion(')
          ..write('filename: $filename, ')
          ..write('sha256: $sha256, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NoteRowsTable noteRows = $NoteRowsTable(this);
  late final $TombstonesTable tombstones = $TombstonesTable(this);
  late final $SyncStateRowsTable syncStateRows = $SyncStateRowsTable(this);
  late final $ImageBlobsTable imageBlobs = $ImageBlobsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [noteRows, tombstones, syncStateRows, imageBlobs];
}

typedef $$NoteRowsTableCreateCompanionBuilder = NoteRowsCompanion Function({
  required String id,
  Value<String> title,
  Value<String> content,
  Value<String> blocksJson,
  Value<String> tagsJson,
  Value<String> attachmentsJson,
  Value<bool> isPinned,
  Value<bool> isArchived,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> dirty,
  Value<DateTime?> remoteRev,
  Value<int> rowid,
});
typedef $$NoteRowsTableUpdateCompanionBuilder = NoteRowsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> content,
  Value<String> blocksJson,
  Value<String> tagsJson,
  Value<String> attachmentsJson,
  Value<bool> isPinned,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> dirty,
  Value<DateTime?> remoteRev,
  Value<int> rowid,
});

class $$NoteRowsTableFilterComposer
    extends Composer<_$AppDatabase, $NoteRowsTable> {
  $$NoteRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get blocksJson => $composableBuilder(
      column: $table.blocksJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attachmentsJson => $composableBuilder(
      column: $table.attachmentsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get remoteRev => $composableBuilder(
      column: $table.remoteRev, builder: (column) => ColumnFilters(column));
}

class $$NoteRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteRowsTable> {
  $$NoteRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get blocksJson => $composableBuilder(
      column: $table.blocksJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attachmentsJson => $composableBuilder(
      column: $table.attachmentsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get remoteRev => $composableBuilder(
      column: $table.remoteRev, builder: (column) => ColumnOrderings(column));
}

class $$NoteRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteRowsTable> {
  $$NoteRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get blocksJson => $composableBuilder(
      column: $table.blocksJson, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get attachmentsJson => $composableBuilder(
      column: $table.attachmentsJson, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get remoteRev =>
      $composableBuilder(column: $table.remoteRev, builder: (column) => column);
}

class $$NoteRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NoteRowsTable,
    NoteRow,
    $$NoteRowsTableFilterComposer,
    $$NoteRowsTableOrderingComposer,
    $$NoteRowsTableAnnotationComposer,
    $$NoteRowsTableCreateCompanionBuilder,
    $$NoteRowsTableUpdateCompanionBuilder,
    (NoteRow, BaseReferences<_$AppDatabase, $NoteRowsTable, NoteRow>),
    NoteRow,
    PrefetchHooks Function()> {
  $$NoteRowsTableTableManager(_$AppDatabase db, $NoteRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> blocksJson = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<String> attachmentsJson = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<DateTime?> remoteRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NoteRowsCompanion(
            id: id,
            title: title,
            content: content,
            blocksJson: blocksJson,
            tagsJson: tagsJson,
            attachmentsJson: attachmentsJson,
            isPinned: isPinned,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            dirty: dirty,
            remoteRev: remoteRev,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> title = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> blocksJson = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<String> attachmentsJson = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> dirty = const Value.absent(),
            Value<DateTime?> remoteRev = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NoteRowsCompanion.insert(
            id: id,
            title: title,
            content: content,
            blocksJson: blocksJson,
            tagsJson: tagsJson,
            attachmentsJson: attachmentsJson,
            isPinned: isPinned,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            dirty: dirty,
            remoteRev: remoteRev,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NoteRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NoteRowsTable,
    NoteRow,
    $$NoteRowsTableFilterComposer,
    $$NoteRowsTableOrderingComposer,
    $$NoteRowsTableAnnotationComposer,
    $$NoteRowsTableCreateCompanionBuilder,
    $$NoteRowsTableUpdateCompanionBuilder,
    (NoteRow, BaseReferences<_$AppDatabase, $NoteRowsTable, NoteRow>),
    NoteRow,
    PrefetchHooks Function()>;
typedef $$TombstonesTableCreateCompanionBuilder = TombstonesCompanion Function({
  required String id,
  required DateTime deletedAt,
  Value<int> rowid,
});
typedef $$TombstonesTableUpdateCompanionBuilder = TombstonesCompanion Function({
  Value<String> id,
  Value<DateTime> deletedAt,
  Value<int> rowid,
});

class $$TombstonesTableFilterComposer
    extends Composer<_$AppDatabase, $TombstonesTable> {
  $$TombstonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$TombstonesTableOrderingComposer
    extends Composer<_$AppDatabase, $TombstonesTable> {
  $$TombstonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TombstonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TombstonesTable> {
  $$TombstonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TombstonesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TombstonesTable,
    Tombstone,
    $$TombstonesTableFilterComposer,
    $$TombstonesTableOrderingComposer,
    $$TombstonesTableAnnotationComposer,
    $$TombstonesTableCreateCompanionBuilder,
    $$TombstonesTableUpdateCompanionBuilder,
    (Tombstone, BaseReferences<_$AppDatabase, $TombstonesTable, Tombstone>),
    Tombstone,
    PrefetchHooks Function()> {
  $$TombstonesTableTableManager(_$AppDatabase db, $TombstonesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TombstonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TombstonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TombstonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TombstonesCompanion(
            id: id,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime deletedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TombstonesCompanion.insert(
            id: id,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TombstonesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TombstonesTable,
    Tombstone,
    $$TombstonesTableFilterComposer,
    $$TombstonesTableOrderingComposer,
    $$TombstonesTableAnnotationComposer,
    $$TombstonesTableCreateCompanionBuilder,
    $$TombstonesTableUpdateCompanionBuilder,
    (Tombstone, BaseReferences<_$AppDatabase, $TombstonesTable, Tombstone>),
    Tombstone,
    PrefetchHooks Function()>;
typedef $$SyncStateRowsTableCreateCompanionBuilder = SyncStateRowsCompanion
    Function({
  Value<int> id,
  Value<DateTime?> lastSyncAt,
  Value<bool> importedFromFirestore,
  Value<bool> firstDrivePushComplete,
  Value<DateTime?> legacyBackupWrittenAt,
  Value<String?> legacyBackupPath,
  Value<DateTime?> lastOrphanScanAt,
});
typedef $$SyncStateRowsTableUpdateCompanionBuilder = SyncStateRowsCompanion
    Function({
  Value<int> id,
  Value<DateTime?> lastSyncAt,
  Value<bool> importedFromFirestore,
  Value<bool> firstDrivePushComplete,
  Value<DateTime?> legacyBackupWrittenAt,
  Value<String?> legacyBackupPath,
  Value<DateTime?> lastOrphanScanAt,
});

class $$SyncStateRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateRowsTable> {
  $$SyncStateRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get importedFromFirestore => $composableBuilder(
      column: $table.importedFromFirestore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get firstDrivePushComplete => $composableBuilder(
      column: $table.firstDrivePushComplete,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get legacyBackupWrittenAt => $composableBuilder(
      column: $table.legacyBackupWrittenAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get legacyBackupPath => $composableBuilder(
      column: $table.legacyBackupPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastOrphanScanAt => $composableBuilder(
      column: $table.lastOrphanScanAt,
      builder: (column) => ColumnFilters(column));
}

class $$SyncStateRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateRowsTable> {
  $$SyncStateRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get importedFromFirestore => $composableBuilder(
      column: $table.importedFromFirestore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get firstDrivePushComplete => $composableBuilder(
      column: $table.firstDrivePushComplete,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get legacyBackupWrittenAt => $composableBuilder(
      column: $table.legacyBackupWrittenAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get legacyBackupPath => $composableBuilder(
      column: $table.legacyBackupPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastOrphanScanAt => $composableBuilder(
      column: $table.lastOrphanScanAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncStateRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateRowsTable> {
  $$SyncStateRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => column);

  GeneratedColumn<bool> get importedFromFirestore => $composableBuilder(
      column: $table.importedFromFirestore, builder: (column) => column);

  GeneratedColumn<bool> get firstDrivePushComplete => $composableBuilder(
      column: $table.firstDrivePushComplete, builder: (column) => column);

  GeneratedColumn<DateTime> get legacyBackupWrittenAt => $composableBuilder(
      column: $table.legacyBackupWrittenAt, builder: (column) => column);

  GeneratedColumn<String> get legacyBackupPath => $composableBuilder(
      column: $table.legacyBackupPath, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOrphanScanAt => $composableBuilder(
      column: $table.lastOrphanScanAt, builder: (column) => column);
}

class $$SyncStateRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncStateRowsTable,
    SyncStateRow,
    $$SyncStateRowsTableFilterComposer,
    $$SyncStateRowsTableOrderingComposer,
    $$SyncStateRowsTableAnnotationComposer,
    $$SyncStateRowsTableCreateCompanionBuilder,
    $$SyncStateRowsTableUpdateCompanionBuilder,
    (
      SyncStateRow,
      BaseReferences<_$AppDatabase, $SyncStateRowsTable, SyncStateRow>
    ),
    SyncStateRow,
    PrefetchHooks Function()> {
  $$SyncStateRowsTableTableManager(_$AppDatabase db, $SyncStateRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<bool> importedFromFirestore = const Value.absent(),
            Value<bool> firstDrivePushComplete = const Value.absent(),
            Value<DateTime?> legacyBackupWrittenAt = const Value.absent(),
            Value<String?> legacyBackupPath = const Value.absent(),
            Value<DateTime?> lastOrphanScanAt = const Value.absent(),
          }) =>
              SyncStateRowsCompanion(
            id: id,
            lastSyncAt: lastSyncAt,
            importedFromFirestore: importedFromFirestore,
            firstDrivePushComplete: firstDrivePushComplete,
            legacyBackupWrittenAt: legacyBackupWrittenAt,
            legacyBackupPath: legacyBackupPath,
            lastOrphanScanAt: lastOrphanScanAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<bool> importedFromFirestore = const Value.absent(),
            Value<bool> firstDrivePushComplete = const Value.absent(),
            Value<DateTime?> legacyBackupWrittenAt = const Value.absent(),
            Value<String?> legacyBackupPath = const Value.absent(),
            Value<DateTime?> lastOrphanScanAt = const Value.absent(),
          }) =>
              SyncStateRowsCompanion.insert(
            id: id,
            lastSyncAt: lastSyncAt,
            importedFromFirestore: importedFromFirestore,
            firstDrivePushComplete: firstDrivePushComplete,
            legacyBackupWrittenAt: legacyBackupWrittenAt,
            legacyBackupPath: legacyBackupPath,
            lastOrphanScanAt: lastOrphanScanAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStateRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncStateRowsTable,
    SyncStateRow,
    $$SyncStateRowsTableFilterComposer,
    $$SyncStateRowsTableOrderingComposer,
    $$SyncStateRowsTableAnnotationComposer,
    $$SyncStateRowsTableCreateCompanionBuilder,
    $$SyncStateRowsTableUpdateCompanionBuilder,
    (
      SyncStateRow,
      BaseReferences<_$AppDatabase, $SyncStateRowsTable, SyncStateRow>
    ),
    SyncStateRow,
    PrefetchHooks Function()>;
typedef $$ImageBlobsTableCreateCompanionBuilder = ImageBlobsCompanion Function({
  required String filename,
  required String sha256,
  required int sizeBytes,
  Value<DateTime?> uploadedAt,
  Value<int> rowid,
});
typedef $$ImageBlobsTableUpdateCompanionBuilder = ImageBlobsCompanion Function({
  Value<String> filename,
  Value<String> sha256,
  Value<int> sizeBytes,
  Value<DateTime?> uploadedAt,
  Value<int> rowid,
});

class $$ImageBlobsTableFilterComposer
    extends Composer<_$AppDatabase, $ImageBlobsTable> {
  $$ImageBlobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get filename => $composableBuilder(
      column: $table.filename, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sha256 => $composableBuilder(
      column: $table.sha256, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => ColumnFilters(column));
}

class $$ImageBlobsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageBlobsTable> {
  $$ImageBlobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get filename => $composableBuilder(
      column: $table.filename, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sha256 => $composableBuilder(
      column: $table.sha256, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => ColumnOrderings(column));
}

class $$ImageBlobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageBlobsTable> {
  $$ImageBlobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => column);
}

class $$ImageBlobsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ImageBlobsTable,
    ImageBlob,
    $$ImageBlobsTableFilterComposer,
    $$ImageBlobsTableOrderingComposer,
    $$ImageBlobsTableAnnotationComposer,
    $$ImageBlobsTableCreateCompanionBuilder,
    $$ImageBlobsTableUpdateCompanionBuilder,
    (ImageBlob, BaseReferences<_$AppDatabase, $ImageBlobsTable, ImageBlob>),
    ImageBlob,
    PrefetchHooks Function()> {
  $$ImageBlobsTableTableManager(_$AppDatabase db, $ImageBlobsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageBlobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageBlobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageBlobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> filename = const Value.absent(),
            Value<String> sha256 = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
            Value<DateTime?> uploadedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageBlobsCompanion(
            filename: filename,
            sha256: sha256,
            sizeBytes: sizeBytes,
            uploadedAt: uploadedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String filename,
            required String sha256,
            required int sizeBytes,
            Value<DateTime?> uploadedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageBlobsCompanion.insert(
            filename: filename,
            sha256: sha256,
            sizeBytes: sizeBytes,
            uploadedAt: uploadedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ImageBlobsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ImageBlobsTable,
    ImageBlob,
    $$ImageBlobsTableFilterComposer,
    $$ImageBlobsTableOrderingComposer,
    $$ImageBlobsTableAnnotationComposer,
    $$ImageBlobsTableCreateCompanionBuilder,
    $$ImageBlobsTableUpdateCompanionBuilder,
    (ImageBlob, BaseReferences<_$AppDatabase, $ImageBlobsTable, ImageBlob>),
    ImageBlob,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NoteRowsTableTableManager get noteRows =>
      $$NoteRowsTableTableManager(_db, _db.noteRows);
  $$TombstonesTableTableManager get tombstones =>
      $$TombstonesTableTableManager(_db, _db.tombstones);
  $$SyncStateRowsTableTableManager get syncStateRows =>
      $$SyncStateRowsTableTableManager(_db, _db.syncStateRows);
  $$ImageBlobsTableTableManager get imageBlobs =>
      $$ImageBlobsTableTableManager(_db, _db.imageBlobs);
}

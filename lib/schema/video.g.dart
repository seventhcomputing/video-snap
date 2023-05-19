// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Video extends _Video with RealmEntity, RealmObjectBase, RealmObject {
  Video(
    String id,
    String fileName,
    String filePath,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'fileName', fileName);
    RealmObjectBase.set(this, 'filePath', filePath);
  }

  Video._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get fileName =>
      RealmObjectBase.get<String>(this, 'fileName') as String;
  @override
  set fileName(String value) => RealmObjectBase.set(this, 'fileName', value);

  @override
  String get filePath =>
      RealmObjectBase.get<String>(this, 'filePath') as String;
  @override
  set filePath(String value) => RealmObjectBase.set(this, 'filePath', value);

  @override
  Stream<RealmObjectChanges<Video>> get changes =>
      RealmObjectBase.getChanges<Video>(this);

  @override
  Video freeze() => RealmObjectBase.freezeObject<Video>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Video._);
    return const SchemaObject(ObjectType.realmObject, Video, 'Video', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('fileName', RealmPropertyType.string),
      SchemaProperty('filePath', RealmPropertyType.string),
    ]);
  }
}

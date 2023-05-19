import 'package:realm/realm.dart';
import 'package:video_snap/schema/video.dart';

class RealmConfig {
  RealmConfig._internal();
  static final RealmConfig _instance = RealmConfig._internal();
  factory RealmConfig() => _instance;

  initialize() {
    Realm(config());
  }

  final List<SchemaObject> schemaList = [
    Video.schema,
  ];

  final defaultRealmName = "video_snap.realm";

  LocalConfiguration config() {
    Configuration.defaultRealmName = defaultRealmName;
    return Configuration.local(schemaList, schemaVersion: 1);
  }
}

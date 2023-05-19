import 'package:realm/realm.dart';

part 'video.g.dart';

@RealmModel()
class _Video {
  @PrimaryKey()
  late String id;
  late String fileName;
  late String filePath;
}

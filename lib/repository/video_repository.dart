import 'package:realm/realm.dart';
import 'package:video_snap/repository/video_interface.dart';
import 'package:video_snap/schema/video.dart';

class VideoRepository implements IVideoRepository {
  @override
  List<Video> findAll(Realm realm) {
    late List<Video> result = [];

    try {
      RealmResults<Video> resultSet =
          realm.query<Video>("TRUEPREDICATE SORT(id ASC)");

      for (Video value in resultSet) {
        result.add(value);
      }
    } catch (e) {
      print("error => $e");
    }
    return result;
  }

  @override
  insert(Realm realm, Video video) {
    try {
      realm.write(() {
        realm.add<Video>(video);
      });
    } catch (e) {
      print("error => $e");
    }
  }

  @override
  Video? findOne(Realm realm, String id) {
    Video? result;

    try {
      result = realm.find<Video>(id);
    } catch (e) {
      print("e => $e");
    }
    return result;
  }
}

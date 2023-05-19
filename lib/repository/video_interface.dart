import 'package:realm/realm.dart';
import 'package:video_snap/schema/video.dart';

abstract class IVideoRepository {
  List<Video> findAll(Realm realm);
  Video? findOne(Realm realm, String id);
  insert(Realm realm, Video video);
}

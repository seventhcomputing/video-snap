import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:realm/realm.dart';
import 'package:video_player/video_player.dart';
import 'package:video_snap/repository/video_repository.dart';
import 'package:video_snap/schema/video.dart';

import 'config/realm_config.dart';

final encryptionKey = Key.fromUtf8('hdSdYIi0plG9xFajxiX9Hb7U62My1zuX');
final initializationVector = IV.fromUtf8('QQU4qPFSIqtvmm5K');

// final encryptionKey = Key.fromLength(32); // Generate a 256-bit encryption key
// final initializationVector =
//     IV.fromLength(16); // Generate a 128-bit initialization vector

class VideoUtil {
  void encryptVideoFile(File inputFile, File outputFile) {
    try {
      final encrypter = Encrypter(AES(encryptionKey));

      final inputFileBytes = inputFile.readAsBytesSync();
      final encryptedBytes = encrypter
          .encryptBytes(inputFileBytes, iv: initializationVector)
          .bytes;

      outputFile.writeAsBytesSync(encryptedBytes);
      // inputFile.deleteSync();
      // insertVideoData(outputFile.path);
    } catch (e) {
      print("error => $e");
    }
  }

  void insertVideoData(String filePath) {
    try {
      final video = Video("1", "butterfly", filePath);
      Realm realm = Realm(RealmConfig().config());
      VideoRepository().insert(realm, video);
    } catch (e) {
      print("error => $e");
    }
  }

  File decryptVideoFileP(
    File inputFile,
    File outputFile,
  ) {
    final encrypter = Encrypter(AES(encryptionKey));
    final inputFileSize = inputFile.lengthSync();
    // final progress = Progress();

    final inputStream = inputFile.openRead();
    final outputStream = outputFile.openWrite();

    int totalReadBytes = 0;

    inputStream.listen((List<int> inputBytes) {
      Uint8List inputFileBytes = inputFile.readAsBytesSync();
      final decryptedBytes = encrypter.decryptBytes(Encrypted(inputFileBytes),
          iv: initializationVector);

      outputStream.add(decryptedBytes);
      totalReadBytes += inputBytes.length;

      final progressPercentage =
          (totalReadBytes / inputFileSize * 100).toStringAsFixed(2);
      print('Decrypting progress: $progressPercentage%');
    }, onDone: () {
      outputStream.close();
      print('Decryption completed successfully.');
    }, onError: (error) {
      print('Decryption failed: $error');
      outputFile
          .deleteSync(); // Delete the incomplete decrypted file if there is an error
    });
    return outputFile;
  }

  void playVideo(String videoPath) {
    final videoPlayerController = VideoPlayerController.file(File(videoPath));

    videoPlayerController.initialize().then((_) {
      videoPlayerController.play();
    });
  }

  File decryptVideoFile(
    File inputFile,
    File outputFile,
  ) {
    final encrypter = Encrypter(AES(encryptionKey));
    final inputFileBytes = inputFile.readAsBytesSync();
    final decryptedBytes = encrypter.decryptBytes(Encrypted(inputFileBytes),
        iv: initializationVector);
    outputFile.writeAsBytesSync(decryptedBytes);

    return outputFile;
  }

  File decryptFile(
    File inputFile,
    File outputFile,
  ) {
    final encrypter = Encrypter(AES(encryptionKey));
    final inputFileBytes = inputFile.readAsBytesSync();
    final decryptedBytes = encrypter.decryptBytes(Encrypted(inputFileBytes),
        iv: initializationVector);
    outputFile.writeAsBytesSync(decryptedBytes);

    return outputFile;
  }
}

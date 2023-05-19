import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:video_snap/video_util.dart';

import 'config/realm_config.dart';
import 'repository/video_repository.dart';
import 'schema/video.dart';

const videoUrl =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  RealmConfig().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomepage(),
    );
  }
}

class MyHomepage extends StatelessWidget {
  const MyHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Download Video")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MyDownloadPage(
            videoUrl: videoUrl,
          ),
          ElevatedButton(
              onPressed: () async {
                final appDocumentsDirectory =
                    await getApplicationDocumentsDirectory();
                final decryptVideoPath =
                    '${appDocumentsDirectory.path}/decrypt-butterfly.mp4';
                final encryptVideoPath =
                    '${appDocumentsDirectory.path}/encrypt-butterfly.mp4';
                VideoUtil().decryptVideoFile(
                    File(encryptVideoPath), File(decryptVideoPath));
              },
              child: const Text("Decrypt Video")),
          ElevatedButton(
              onPressed: () async {
                Realm realm = Realm(RealmConfig().config());

                Video? video = VideoRepository().findOne(realm, "1");
                if (video != null) {
                  final videoFilePath = video.filePath;
                  print("videoFilePath => $videoFilePath");
                }

                // final appDocumentsDirectory =
                //     await getApplicationDocumentsDirectory();

                // final decryptVideoPath =
                //     '${appDocumentsDirectory.path}/decrypt-butterfly.mp4';
                // final encryptVideoPath =
                //     '${appDocumentsDirectory.path}/encrypt-butterfly.mp4';
                // File decryptedVideoFile = VideoUtil().decryptVideoFile(
                //     File(encryptVideoPath), File(decryptVideoPath));
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: (context) => VideoView(decryptedVideoFile)));
              },
              child: const Text("Play Video")),
          ElevatedButton(
              onPressed: () async {
                final appDocumentsDirectory =
                    await getApplicationDocumentsDirectory();
                final decryptVideoPath =
                    '${appDocumentsDirectory.path}/decryptp-butterfly.mp4';
                final encryptVideoPath =
                    '${appDocumentsDirectory.path}/encrypt-butterfly.mp4';
                VideoUtil().decryptVideoFileP(
                    File(encryptVideoPath), File(decryptVideoPath));
              },
              child: const Text("Decrypt With Progress"))
        ],
      ),
    );
  }
}

class MyDownloadPage extends StatelessWidget {
  const MyDownloadPage({super.key, required this.videoUrl});

  final videoUrl;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text('Download'),
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return DownloadDialog(url: videoUrl);
            },
          );
        },
      ),
    );
  }
}

class DownloadDialog extends StatefulWidget {
  final String url;

  const DownloadDialog({super.key, required this.url});

  @override
  _DownloadDialogState createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    downloadVideo(widget.url);
  }

  void downloadVideo(String url) async {
    final dio = Dio();
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final savePath = '${appDocumentsDirectory.path}/butterfly.mp4';
    final saveOutputPath =
        '${appDocumentsDirectory.path}/encrypt-butterfly.mp4';
    try {
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (receivedBytes, totalBytes) {
          if (totalBytes != -1) {
            final newProgress = receivedBytes / totalBytes;
            setState(() {
              progress = newProgress;
            });
          }
        },
      );

      Navigator.of(context).pop(); // Close the download progress dialog
      print('Video downloaded successfully');
      print('Saved file path: $savePath');
    } catch (e) {
      print('Error downloading video: $e');
    }
    await Future.delayed(const Duration(seconds: 1));
    VideoUtil().encryptVideoFile(File(savePath), File(saveOutputPath));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Downloading...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 10.0),
          Align(
              alignment: Alignment.bottomRight,
              child: Text('${(progress * 100).toStringAsFixed(0)}%')),
        ],
      ),
    );
  }
}

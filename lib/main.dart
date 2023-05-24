import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:realm/realm.dart';
import 'package:video_snap/file_render_view.dart';

import 'package:video_snap/video_util.dart';
import 'package:video_snap/video_view.dart';

import 'config/realm_config.dart';
import 'repository/video_repository.dart';
import 'schema/video.dart';

import 'package:pdf/widgets.dart' as pw;

const videoUrl =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

const pdfUrl =
    "https://github.com/seventhcomputing/video-snap/raw/master/sample.pdf";

const pptxUrl =
    "https://github.com/seventhcomputing/video-snap/raw/master/samplepptx.pptx";

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
      appBar: AppBar(title: const Text("Download")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MyDownloadPage(
            videoUrl,
            downloadFileName: "butterfly.mp4",
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

                final appDocumentsDirectory =
                    await getApplicationDocumentsDirectory();

                final decryptVideoPath =
                    '${appDocumentsDirectory.path}/decrypt-butterfly.mp4';
                final encryptVideoPath =
                    '${appDocumentsDirectory.path}/encrypt-butterfly.mp4';
                File decryptedVideoFile = VideoUtil().decryptVideoFile(
                    File(encryptVideoPath), File(decryptVideoPath));
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VideoView(decryptedVideoFile)));
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
              child: const Text("Decrypt With Progress")),
          const MyDownloadPage(
            pdfUrl,
            downloadFileName: "sample.pdf",
          ),
          ElevatedButton(
              onPressed: () async {
                try {
                  if (await Permission.manageExternalStorage
                      .request()
                      .isGranted) {
                    final appDocumentsDirectory =
                        await getApplicationDocumentsDirectory();
                    final decryptPath =
                        '${appDocumentsDirectory.path}/sample.pdf';

                    // final result = await OpenFile.open(decryptPath);
                    // print('result => ${result.type}');
                    // print('result => ${result.message}');
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return PDFViewerPage(decryptPath);
                    }));
                  }
                } catch (e) {
                  print("open file error => $e");
                }
              },
              child: const Text("Open PDF")),
          const MyDownloadPage(
            pptxUrl,
            downloadFileName: "samplepptx.pptx",
          ),
          ElevatedButton(
              onPressed: () async {
                try {
                  if (await Permission.manageExternalStorage
                      .request()
                      .isGranted) {
                    final appDocumentsDirectory =
                        await getApplicationDocumentsDirectory();
                    // final decryptPath =
                    //     '${appDocumentsDirectory.path}/samplepptx.pptx';
                    final decryptPath =
                        '${appDocumentsDirectory.path}/sample.pdf';
                    // await convertPPTXtoPDF(decryptPath);
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return FileReaderPage(filePath: decryptPath);
                    }));
                    // Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    //   return PowerPointViewerPage(pptPath: decryptPath);
                    // }));
                    // final result = await OpenFile.open(decryptPath);
                    // print('result => ${result.type}');
                    // print('result => ${result.message}');
                  }
                } catch (e) {
                  print("open file error => $e");
                }
              },
              child: const Text("Open Power Point")),
        ],
      ),
    );
  }

  Future<void> convertPPTXtoPDF(String pptxFilePath) async {
    final ByteData image = await rootBundle.load('assets/sampleImage.png');
    Uint8List imageData = (image).buffer.asUint8List();
    final pdf = pw.Document();

    // // Create PDF page from PPTX bytes

    final pptxImage = pw.MemoryImage(imageData);

    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Image(pptxImage);
    }));

    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/convert.pdf");
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
  }
}

class MyDownloadPage extends StatelessWidget {
  const MyDownloadPage(this.url, {super.key, required this.downloadFileName});

  final url;
  final downloadFileName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text('Download - $downloadFileName'),
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return DownloadDialog(
                url,
                downloadFileName: downloadFileName,
              );
            },
          );
        },
      ),
    );
  }
}

class DownloadDialog extends StatefulWidget {
  final String url;
  final String downloadFileName;

  const DownloadDialog(this.url, {super.key, required this.downloadFileName});

  @override
  _DownloadDialogState createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    downloadVideo(widget.url, downloadFileName: widget.downloadFileName);
  }

  void downloadVideo(String url, {required String downloadFileName}) async {
    final dio = Dio();
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final savePath = '${appDocumentsDirectory.path}/$downloadFileName';
    final saveOutputPath =
        '${appDocumentsDirectory.path}/encrypt-$downloadFileName';
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
    print("progress => $progress");
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

class PDFViewerPage extends StatelessWidget {
  PDFViewerPage(
    this.path, {
    super.key,
  });

  late String path;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Easiest PDF sample'),
            ),
            backgroundColor: Colors.grey,
            body: PdfViewer.openFile(path)));
  }
}

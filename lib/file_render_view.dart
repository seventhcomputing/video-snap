import 'package:flutter/material.dart';
import 'package:flutter_filereader/flutter_filereader.dart';

class FileReaderPage extends StatefulWidget {
  final String filePath;

  const FileReaderPage({super.key, Key = Key, required this.filePath});

  @override
  _FileReaderPageState createState() => _FileReaderPageState();
}

class _FileReaderPageState extends State<FileReaderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("doc"),
      ),
      body: FileReaderView(
        filePath: widget.filePath,
      ),
    );
  }
}

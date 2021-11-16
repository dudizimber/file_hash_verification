import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();

  bool loading = false;
  String message = '';

  @override
  void initState() {
    super.initState();
  }

  setLoading(bool state, [String msg = '']) {
    print(msg);
    setState(() {
      loading = state;
      message = msg;
    });
  }

  _hash() async {
    try {
      setLoading(true, 'Starting...');

      String path = _controller.text;
      // Sets the output path to be external storage on android; same root folder on other platforms
      String zipPath = Platform.isAndroid
          ? '${(await getExternalStorageDirectory())?.path}/${path.split('/').last}.zip'
          : '$path.zip';

      var dir = Directory(path);

      if (!dir.existsSync()) {
        return setLoading(false, 'Not a folder');
      }

      setLoading(true, 'Compressing...');

      _compress(dir, zipPath);

      setLoading(true, 'Getting hash...');

      String hash = _getHashFromFile(File(zipPath));

      setLoading(false, 'Hash: $hash');
    } catch (e) {
      return setLoading(false, '$e');
    }
  }

  String _getHashFromFile(File file) {
    var bytes = utf8.encode(file.readAsBytesSync().toString());
    var digest = md5.convert(bytes);
    return digest.toString();
  }

  _compress(Directory dir, String compressedFilePath) {
    var encoder = ZipFileEncoder();
    encoder.zipDirectory(
      dir,
      filename: compressedFilePath,
      modified: DateTime(2000),
    );
    return compressedFilePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Input the folder location'),
              TextField(
                controller: _controller,
              ),
              ElevatedButton(
                onPressed: loading ? null : _hash,
                child: Text('Start'),
              ),
              Text('$message'),
            ],
          ),
        ),
      ),
    );
  }
}

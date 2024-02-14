import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _textEditingController = TextEditingController();
  final GlobalKey _globalKey = GlobalKey();
  ui.Image? _capturedImage;
  Uint8List? _imageBytes;
  String _displayText = '';
  Widget? _displayedImageWidget;

  Future<void> _captureImage() async {
    RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      setState(() {
        _capturedImage = image;
        _imageBytes = byteData.buffer.asUint8List();
        _displayedImageWidget = Image.memory(_imageBytes!);
      });
    }
  }

  Future<void> _saveImageToGallery() async {
    if (_imageBytes == null) return;
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/image.png').writeAsBytes(_imageBytes!);
    final result = await GallerySaver.saveImage(file.path, albumName: "YourAlbumName");
    print("이미지 저장 성공: $result");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Text and Image Processing')),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(hintText: 'Enter multiline text here'),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: TextStyle(fontSize: 22, color: Colors.black),
                ),
              ),
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  color: Colors.transparent,
                  child: Text(
                    _textEditingController.text,
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save the current text with line breaks
                  setState(() {
                    _displayText = _textEditingController.text;
                  });
                },
                child: Text('Show Text'),
              ),
              ElevatedButton(
                onPressed: () {
                  _captureImage();
                },
                child: Text('Capture and Show Image'),
              ),
              ElevatedButton(
                onPressed: _saveImageToGallery,
                child: Text('Save Image to Gallery'),
              ),
              if (_displayText.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(_displayText, // Display text with line breaks
                      style: TextStyle(fontSize: 22, color: Colors.black)),
                ),
              if (_displayedImageWidget != null)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _displayedImageWidget!,
                      Text('Width: ${_capturedImage?.width}, Height: ${_capturedImage?.height}'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart'; // Ensure GetX is still used for dependency injection.
import 'package:screenshot/screenshot.dart';

class TapController extends GetxController {
  var startStr = 'Tap Somewhere'.obs;
  var endStr = ''.obs;
  var dragStr = ''.obs; // Add this line for drag coordinates
  bool isDrawing = false;

  // starting point
  Offset? start;

  // dragging point
  Offset? drag;

  // ending point
  Offset? end;

  void updateUI() {
    // Calls GetxController's update method to update the UI
    update();
  }

  void reset() {
    start = null;
    drag = null;
    end = null;
    isDrawing = false;
    updateUI();
  }

  void notifyEnd() {
    isDrawing = false;
    updateUI();
  }

  // Add this method for updating drag coordinates
  void updateDragCoordinates(Offset newCoordinates) {
    if (!isDrawing) {
      // If the user is not dragging, then the current drag coordinates are the starting point
      updateStartingPoint(newCoordinates);
    }
    // Update the drag coordinates
    updateDragPoint(newCoordinates);

    isDrawing = true;
  }

  void updateStartingPoint(Offset newStart) {
    startStr.value = newStart.toString();
    start = newStart;
    updateUI();
  }

  void updateDragPoint(Offset newDrag) {
    dragStr.value = newDrag.toString();
    drag = newDrag;
    updateUI();
  }

  void updateEndingPoint(Offset newEnd) {
    endStr.value = newEnd.toString();
    end = newEnd;
    updateUI();
  }
}

class ImageController extends GetxController {
  var image = Rx<ui.Image?>(null);
  var width = 0.0;
  var height = 0.0;

  void updateUI() {
    // Calls GetxController's update method to update the UI
    update();
  }

  void updateImage(ui.Image newImage) {
    image.value = newImage;
    updateUI();
  }

  Future<ui.Image> createDefaultWhiteImage(double width, double height) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    return img;
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TapController tapController = Get.put(TapController());
    final ImageController imageController = Get.put(ImageController());

    return GetMaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('GetX Dragging End Coordinates App'),
        ),
        body: GestureDetector(
          onTapDown: (TapDownDetails details) {},
          onPanUpdate: (DragUpdateDetails details) {
            // Apply grid to the details.localPosition to make the drag coordinates snap to the grid
            final x = (details.localPosition.dx / 10).round() * 10;
            final y = (details.localPosition.dy / 10).round() * 10;
            // Keep updating the drag coordinates and the end position as the user drags
            tapController
                .updateDragCoordinates(Offset(x.toDouble(), y.toDouble()));
            tapController.updateEndingPoint(Offset(x.toDouble(), y.toDouble()));
          },
          onPanEnd: (DragEndDetails details) async {
            // When the user stops dragging, notify the controller
            tapController.notifyEnd();

            if (tapController.start != null && tapController.end != null) {
              // Calculate the width and height of the rectangle
              final width =
                  (tapController.end!.dx - tapController.start!.dx).abs();
              final height =
                  (tapController.end!.dy - tapController.start!.dy).abs();
              // // 탭 컨트롤러가 그린 사각형의 위치와 사이즈에 딱 맞게 이미지를 보여주게 함.
              // // 일단 흰색 이미지로 테스트
              // final image = await imageController.createDefaultWhiteImage(width, height);
              // imageController.updateImage(image);

              // 이미지 컨트롤러에 사각형의 너비와 높이를 전달하여 사각형의 너비와 높이를 업데이트
              imageController.width = width;
              imageController.height = height;

              // Navigate to the SquareDetailsScreen and pass the width and height as arguments
              final capturedImage = await Get.to(() => SquareDetailsScreen(width: width, height: height));
              if (capturedImage!= null) {

                // 이미지를 보여주는 위젯에 이미지를 업데이트
                imageController.updateImage(capturedImage);
                print('이미지 업데이트');
              }else{
                print('이미지 업데이트 실패');
              }
            }
          },
          child: Stack(
            children: [
              Container(
                color: Colors.lightBlueAccent,
                alignment: Alignment.center,
                child: GetBuilder<TapController>(
                  builder: (_) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Start: ${_.startStr.value}"),
                      SizedBox(height: 20),
                      Text("Drag: ${_.dragStr.value}"),
                      SizedBox(height: 20),
                      Text("End: ${_.endStr.value}"),
                    ],
                  ),
                ),
              ),
              GetBuilder<TapController>(
                builder: (_) {
                  final start = _.start;
                  final end = _.end;
                  print('start: $start, end: $end');
                  if (start != null && end != null) {
                    final rect = Rect.fromPoints(start, end);
                    return CustomPaint(
                      painter: RectanglePainter(rect: rect),
                      child: Container(),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              GetBuilder<ImageController>(
                builder: (imageCtrl) {
                  if (imageCtrl.image.value != null) {
                    return Positioned(
                      top: tapController.start?.dy ?? 0,
                      left: tapController.start?.dx ?? 0,
                      child: CustomPaint(
                        size: Size(imageController.width, imageController.height), // Use the designated frame size.
                        painter: ImagePainter(image: imageCtrl.image.value!, width: imageController.width, height: imageController.height),
                      ),
                    );
                  } else {
                    return Container(); // Or any placeholder you prefer.
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;
  final double width;
  final double height;

  ImagePainter({required this.image, required this.width, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(canvas: canvas, rect: Rect.fromLTWH(0, 0, width, height), image: image);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class RectanglePainter extends CustomPainter {
  final Rect? rect;

  RectanglePainter({this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    if (rect != null) {
      final paint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(rect!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RectanglePainter oldDelegate) => true;
}

class SquareDetailsScreen extends StatefulWidget {
  final double width;
  final double height;

  SquareDetailsScreen({Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  _SquareDetailsScreenState createState() => _SquareDetailsScreenState();
}

class _SquareDetailsScreenState extends State<SquareDetailsScreen> {
  final TextEditingController _textController = TextEditingController();
  String rareText = ""; // State variable for holding rare text
  String formattedText = ""; // State variable for holding formatted text

  final double fontSizeDefault = 80;
  final FontWeight fontWeightDefault = FontWeight.bold;

  // Initialize textStyle using the default font size and weight
  late TextStyle textStyle;
  final TextAlign textAlignment = TextAlign.center;

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  Uint8List? _capturedImageBytes;
  ui.Image? _capturedImage;

  Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Center(child: Image.memory(capturedImage)),
      ),
    );
  }

  Widget _textSticker(double width, double height, String formattedText,
      TextStyle textStyle, TextAlign textAlignment) {
    return Container(
      // 패딩 0으로 설정
      padding: EdgeInsets.zero,
      width: width,
      height: height,
      decoration: BoxDecoration(
        // 여기에서 테두리를 정의
        border: Border.all(
          color: Colors.grey[800]!, // 테두리 색상
          width: 0.0, // 테두리 두께
        ),
        color: Colors.transparent, // 컨테이너 배경색을 투명하게 설정
      ),
      alignment: Alignment.center,
      child: Text(
        formattedText, // rareText, // Display the rare text here
        style: textStyle,
        textAlign: textAlignment,
      ),
    );
  }

  Future<void> _saveImageToGallery(Uint8List? byteData) async {
    // 임시디렉토리
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/image.png';
    final imagePath = '${dir.path}/image.png';

    if (byteData != null) {
      // save as png
      File(filePath).writeAsBytes(byteData!);
      final result = await ImageGallerySaver.saveFile(imagePath);

      print(result);
    }
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(textChanged);
  }

  void textChanged() {
    // 여기에서 formattedText를 업데이트하지 않고,
    // 대신 _LineBreaksTrackingTextFieldState 내부에서 처리합니다.
  }

  @override
  void dispose() {
    _textController.removeListener(textChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 디바이스의 텍스트 스케일 팩터 값을 가져옵니다.
    final deviceScaledFontSize =
        MediaQuery.textScalerOf(context).scale(fontSizeDefault);

    // Initialize textStyle here to use it in textChanged
    textStyle = TextStyle(
      fontSize: deviceScaledFontSize,
      fontWeight: fontWeightDefault,
      color: Colors.grey[800],
      height: 1.0,
      letterSpacing: null,
      // 디폴트와 같다. 명시적으로 표시하기 위해 추가함.
      wordSpacing: null, // 디폴트와 같다. 명시적으로 표시하기 위해 추가함.
    );

    return Scaffold(
      appBar: AppBar(title: Text('Square Details')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Divider(),
            Text(
              'Text Sticker',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // button to capture the green container as an image
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    var container = _textSticker(widget.width, widget.height,
                        formattedText, textStyle, textAlignment);
                    screenshotController
                        .captureFromWidget(
                      container,
                      pixelRatio: 3.0,
                      delay: Duration(milliseconds: 10),
                    )
                        .then((capturedImageBytes) async {
                      // save the captured image to _capturedImageBytes
                      setState(() {
                        _capturedImageBytes = capturedImageBytes;
                      });

                      // ShowCapturedWidget(context, capturedImageBytes);
                      _saveImageToGallery(capturedImageBytes);
                      // get back to the main screen
                      Navigator.pop(context, _capturedImage); // Pass the image bytes back
                    });
                  },
                  // Text to display in the button and width, height of the green container
                  child:
                      Text('Capture Image, ${widget.width}x${widget.height}'),
                ),
              ],
            ),

            // Center(
            //   child: GestureDetector(
            //     onTap: () {
            //
            //     },
            //       child: _textSticker(
            //           widget.width, widget.height, formattedText, textStyle, textAlignment),
            //   ),
            // ),
            Divider(),
            Text(
              'Formatted Text:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              width: double.infinity,
              color: Colors.yellow[100],
              child: Text(formattedText, // Display the formatted text here
                  style: textStyle,
                  textAlign: textAlignment),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: LineBreaksTrackingTextField(
                controller: _textController,
                maxLength: 1000,
                labelText: 'Enter Text',
                width: widget.width,
                height: widget.height,
                textStyle: textStyle,
                textAlign: textAlignment,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                onTextChanged: (String newRareText, String newFormattedText) {
                  // 여기에서 상태를 업데이트합니다.
                  setState(() {
                    rareText = newRareText;
                    formattedText = newFormattedText;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 상위 위젯에 대한 콜백 함수 타입을 정의합니다.
typedef OnTextChanged = void Function(String rareText, String formattedText);

class LineBreaksTrackingTextField extends StatefulWidget {
  final TextEditingController controller;
  final double width, height;
  final int maxLength;

  final TextStyle? textStyle;
  final TextAlign textAlign;

  final String labelText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final MaxLengthEnforcement maxLengthEnforcement;
  final OnTextChanged onTextChanged; // 상위 위젯으로 텍스트 변경 사항을 전달하기 위한 콜백

  LineBreaksTrackingTextField({
    Key? key,
    required this.controller,
    required this.width,
    required this.height,
    this.maxLength = TextField.noMaxLength, // 기본값으로 제한 없음 설정

    required this.textStyle, // 텍스트 스타일을 필수로 설정
    required this.textAlign, // 텍스트 정렬을 필수로 설정

    this.labelText = '', // 기본 라벨 텍스트 설정
    this.keyboardType = TextInputType.multiline,
    this.textInputAction = TextInputAction.newline,
    this.maxLengthEnforcement = MaxLengthEnforcement.none,
    required this.onTextChanged, // 콜백 함수를 생성자 파라미터로 추가
  }) : super(key: key);

  @override
  _LineBreaksTrackingTextFieldState createState() =>
      _LineBreaksTrackingTextFieldState();
}

class _LineBreaksTrackingTextFieldState
    extends State<LineBreaksTrackingTextField> {
  void _handleTextChange() {
    String text = widget.controller.text;

    String LoremIpsum =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n"
        "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n"
        "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n"
        "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.";
    // 여기서 사용자 입력 뒤에 "(LoremIpsum)"를 추가합니다.
    String rareText = "$text(${LoremIpsum})";

    // 현재 텍스트에서 수동 줄바꿈 위치 찾기
    List<int> manualBreaks = _findManualLineBreaks(rareText);

    // 컨테이너 높이에 마진을 추가하여 컨테이너 높이를 계산
    double containerHeightWithMargin =
        widget.height - widget.textStyle!.fontSize! * 0.5;

    // 최대 줄 수를 예상하고, 수동 줄바꿈에 의한 줄 수가 최대 줄 수를 넘어가지 않도록 rareText를 우선 제한. 자동 줄바꿈 계산 부하를 줄이기 위해 먼저 적용한 것.
    int maxLines = _getMaxLines(containerHeightWithMargin, widget.textStyle!);
    LineBreakResult maxLineBreakResult =
        _restrictTextLines(rareText, manualBreaks, maxLines);

    // 탭을 공백으로 변환하고, 변환된 텍스트와 조정된 줄바꿈 위치를 받아옴
    LineBreakResult tabResult = _replaceTabsWithSpaces(
        maxLineBreakResult.formattedText, maxLineBreakResult.breakPositions);

    // Widget의 너비에 폰트의 너비만큼의 여유 공간을 뺀 값을 컨테이너 너비로 설정
    double containerWidth = widget.width - widget.textStyle!.fontSize! * 2;

    // 내부적으로 자동 줄바꿈 위치를 추정하고, 줄바꿈을 삽입.
    LineBreakResult lineBreakResult = _estimateAndInsertLineBreaks(
        tabResult.formattedText,
        tabResult.breakPositions,
        widget.textStyle!,
        containerWidth);

    // // lineBreakResult.formattedText의 높이를 textPainter로 계산하여, containerHeight보다 크면 마지막 줄부터 차례로 제거하여 허용되는 높이까지 줄이는 함수.
    // LineBreakResult lineBreakResultFinal = _reduceLinesToContainerHeight(lineBreakResult.formattedText, lineBreakResult.breakPositions, containerHeightWithMargin, widget.textStyle!);

    // 최종적으로 텍스트 필드에 표시할 줄바꿈되고 제한된 텍스트를 가져옴.
    LineBreakResult maxLineBreakResultFinal = _restrictTextLines(
        lineBreakResult.formattedText,
        lineBreakResult.breakPositions,
        maxLines);

    // print('lineBreakResultFinal: ${lineBreakResultFinal.breakPositions}');
    print('maxLineBreakResultFinal: ${maxLineBreakResultFinal.breakPositions}');

    // 상위 위젯의 콜백 함수를 호출하여 변경된 텍스트를 전달합니다.
    widget.onTextChanged(rareText, maxLineBreakResultFinal.formattedText);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      maxLength: widget.maxLength,
      maxLines: null,
      // 멀티라인 입력을 허용
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: widget.labelText,
      ),
      style: widget.textStyle,
      maxLengthEnforcement: widget.maxLengthEnforcement,
    );
  }

  List<int> _findManualLineBreaks(String text) {
    List<int> breaks = [];
    List<String> lines = text.split('\n');
    int cumulativeLength = 0;
    for (var line in lines) {
      cumulativeLength += line.length;
      breaks.add(cumulativeLength);
      cumulativeLength++; // '\n' 문자 길이 추가
    }
    print('manual breaks: $breaks');
    return breaks;
  }

  LineBreakResult _estimateAndInsertLineBreaks(String text,
      List<int> manualBreaks, TextStyle textStyle, double containerWidth) {
    // 줄바꿈이 있는 위치를 기준으로 LineBreakResult를 줄별로 나누어서 리스트에 저장하고 반환하는 함수
    List<String> SingleLineTexts = _splitLineBreakResultsByLine(text);

    // 각 라인에 관한 자동 줄바꿈 위치를 추정하고, 다시한번 더  쪼개어진 문자열의 리스트로 반환.
    // 인풋은 [수동라인1, 수동라인2] => 결과는 [[자동라인1, 자동라인2], [자동라인3, 자동라인4, 자동라인5]]
    List<List<List<String>>> formattedLineBreakResults =
        SingleLineTexts.map((line) {
      if (line.isEmpty) {
        // For empty lines, return a list with an empty string to ensure it's not skipped
        return [
          [line]
        ]; // Represents an empty line
      }
      return _estimateAutomaticLineBreaks(line, textStyle, containerWidth);
    }).toList();
    print('formattedLineBreakResults: $formattedLineBreakResults');
    // 리스트의 각 요소는 라인별로 나누어진 문자열을 포함하고 있음. 다음과 같이 이중으로 되어 있을 수 있음. [[[first line], [second line]], [third line]]
    // 라인 단위로 나누어진 문자열을 하나의 문자열로 합치며, 줄바꿈 문자를 추가하여 하나의 문자열로 만들고, 줄바꿈 위치를 반환하는 함수
    // formattedLineBreakResults 의 요소를 가장 바깥쪽에서 순회하면서, 각 요소를 다시 순회하면서, 각 요소를 하나의 문자열로 합치면서 해당 접점 인덱스를 함께 반환
    // 즉, map을 사용하여 formattedLineBreakResults의 요소를 순회하면서, 각 요소를 join하여 하나의 문자열로 만들고, 각 요소가 join된 접점 인덱스를 함께 LineBreakResult로 반환
    // 예를 들어,[[[]], [[(Lorem,  ], [ipsum,  ], [dolor,  , sit,  ]], [[Sed,  , do,  ], [eiusmod,  ], [tempor,  ]] ]

    String fullLines = "";
    int fullLineBreaks = 0;
    List<int> fullBreaks = [];
    for (int i = 0; i < formattedLineBreakResults.length; i++) {
      for (int j = 0; j < formattedLineBreakResults[i].length; j++) {
        List<String> line = formattedLineBreakResults[i][j];
        String lineText = line.join('');
        // i, j 모두 마지막 라인이 아니면, 줄바꿈 문자를 추가
        if (i != formattedLineBreakResults.length - 1 ||
            j != formattedLineBreakResults[i].length - 1) {
          lineText += '\n';
        }
        fullLines += lineText;
        fullLineBreaks += lineText.length;
        fullBreaks.add(fullLineBreaks);

        print('lineText: $lineText');
      }
    }
    print('fullLines: $fullLines');
    print('fullBreaks: $fullBreaks');

    return LineBreakResult(fullBreaks, fullLines);
  }

  List<String> _splitLineBreakResultsByLine(String multiLineText) {
    return multiLineText.split('\n');
  }

  List<List<String>> _estimateAutomaticLineBreaks(
      String text, TextStyle textStyle, double containerWidth) {
    // 복잡한 로직 구현 필요. 여기서는 단순히 자동 줄바꿈 위치를 반환

    // 여기서는 단어와 공백을 분리하는 데 사용할 수 있는 함수를 사용하여 단어와 공백을 분리함.
    List<String> wordsAndSpaces = _splitTextIntoWordsAndSpaces(text);
    print('wordsAndSpaces: $wordsAndSpaces');

    // 리스트의 각 문자열 요소의 너비를 계산하는 함수
    List<double> wordWidths =
        _calculateTextSegmentWidths(wordsAndSpaces, textStyle);
    print('wordWidths: $wordWidths');

    // 테스트로 두번째 단어부터 세 번째 단어만 너비 합산
    // double sum = wordWidths.sublist(0, 3).fold(0, (prev, element) => prev + element);
    // print('sum: $sum');
    print('containerWidth: $containerWidth');
    // 차례로 단어의 너비를 더해가면서, 컨테이너 너비를 넘어가기 직전의 단어 인덱스를 찾음
    // 예를 들어, 단어 1, 2, 3의 너비 합이 컨테이너 너비를 넘어가면, 단어 1, 2까지만 표시하고 줄바꿈
    // 만약, 단어 1만으로도 컨테이너 너비를 넘어가면, 단어를 문자로 쪼개어 다시 더해가면서 너비를 계산
    // longlongword라는 단어가 컨테이너 너비를 넘어가면, ['l', 'o', 'n', 'g', 'l', 'o', 'n', 'g', 'w', 'o', 'r', 'd']로 쪼개고 다시 너비를 계산

    // 차례로 단어의 너비를 더하면서, 컨테이너 너비를 넘어가기 직전의 단어 인덱스를 찾고 그 인덱스까지의 단어를 결합하여 result에 추가
    // 그 다음 인덱스부터 다시 너비를 더하면서 컨테이너 너비를 넘어가기 직전의 단어 인덱스를 찾고 그 인덱스까지의 단어를 결합하여 result에 추가
    // 이 과정을 반복.
    // 단, 그 자체만으로 컨테이너 너비를 넘어가는 단어가 있을 경우, 단어를 문자로 쪼개어 다시 더해가면서 너비를 계산하고 그 인덱스까지의 문자를 결합하여 result에 추가
    // 그 다음 인덱스부터 다시 너비를 더하면서 컨테이너 너비를 넘어가기 직전의 단어 인덱스를 찾고 그 인덱스까지의 단어를 결합하여 result에 추가
    // 이 과정을 반복.
    // 단, 문자도 그 자체만으로 컨테이너 너비를 넘어가는 경우는 없음. 따라서 최소 컨테이너 너비는 문자 너비보다는 크다고 가정함.
    List<List<String>> result = compareWidthsIteratively(
        wordsAndSpaces, wordWidths, containerWidth, textStyle);

    print('result: $result');

    return result;
  }

  List<List<String>> compareWidthsIteratively(List<String> segments,
      List<double> widths, double containerWidth, TextStyle textStyle) {
    List<List<String>> lines = []; // Stores lines of words
    List<String> currentLine = []; // Current line being constructed
    double currentLineWidth = 0.0; // Width of the current line

    for (int i = 0; i < segments.length; i++) {
      String segment = segments[i];
      double segmentWidth = widths[i];

      if (segmentWidth > containerWidth) {
        // If a single segment exceeds the container width, split it
        List<String> splitSegment = segment.split('');
        for (var char in splitSegment) {
          double charWidth = measureTextWidth(char, textStyle);
          if (currentLineWidth + charWidth > containerWidth) {
            // Add current line to lines and start a new line
            if (currentLine.isNotEmpty) {
              lines.add(List.from(currentLine));
              currentLine.clear();
            }
            currentLineWidth = 0.0;
          }
          currentLine.add(char);
          currentLineWidth += charWidth;
        }
      } else if (currentLineWidth + segmentWidth <= containerWidth) {
        // Add the segment to the current line
        currentLine.add(segment);
        currentLineWidth += segmentWidth;
      } else {
        // The segment doesn't fit in the current line, so start a new line
        if (currentLine.isNotEmpty) {
          lines.add(List.from(currentLine));
          currentLine.clear();
        }
        currentLine.add(segment);
        currentLineWidth = segmentWidth;
      }
    }

    // Add the last line if it's not empty
    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }

  List<double> _calculateTextSegmentWidths(
      List<String> textSegments, TextStyle textStyle) {
    return textSegments.map((word) {
      return measureTextWidth(word, textStyle);
    }).toList();
  }

  double measureTextWidth(String text, TextStyle textStyle) {
    int maxLines = text.split('\n').length;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
  }

  // 안 씀. 테스트를 위해 만들어 놓음.
  List<double> _calculateTextSegmentHeights(
      List<String> textSegments, TextStyle textStyle) {
    return textSegments.map((word) {
      return measureTextHeight(word, textStyle);
    }).toList();
  }

  double measureTextHeight(String text, TextStyle textStyle) {
    if (text.isEmpty) {
      text = ' '; // 한 줄짜리 텍스트의 높이를 구하기 위해 빈 문자열이면 공백 문자로 대체
    }
    int maxLines = text.split('\n').length;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.height;
  }

  int _getMaxLines(double containerHeight, TextStyle style) {
    // 텍스트 페인터를 사용해서 텍스트가 특정 높이 내에 몇 줄이 들어갈 수 있는지 계산
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: ' ', style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity);
    // 텍스트가 들어갈 컨테이너에 높이 마진을 주어서 텍스트가 안전하게 들어갈 수 있도록 함

    print('fontSize: ${style.fontSize}');
    print('containerHeightWithMargin: $containerHeight');
    int maxLines = (containerHeight / textPainter.preferredLineHeight).floor();
    print('maxLines: $maxLines');
    return maxLines;
  }

  LineBreakResult _restrictTextLines(
      String text, List<int> breakPositions, int maxLines) {
    List<int> adjustedBreakPositions = List<int>.from(breakPositions);
    String adjustedText = text;
    // 줄바꿈 횟수가 최대 줄바꿈 횟수를 넘어가면, 줄바꿈 위치를 조정하고, 문자열을 조정
    int maxBreaks = maxLines - 1;
    if (breakPositions.length >= maxBreaks) {
      adjustedBreakPositions = adjustedBreakPositions.sublist(0, maxBreaks);
      adjustedText =
          adjustedText.substring(0, adjustedBreakPositions[maxBreaks - 1]);
    }

    // 마지막 줄바꿈 인덱스를 제거
    adjustedBreakPositions.removeLast();
    // 적용텍스트에서 마지막 줄바꿈 문자 제거
    adjustedText = adjustedText.substring(0, adjustedText.length - 1);

    print('adjustedBreakPositions: $adjustedBreakPositions');
    print('adjustedText: $adjustedText');
    // 조정된 줄바꿈 위치와 조정된 문자열을 포함하는 결과 반환
    return LineBreakResult(adjustedBreakPositions, adjustedText);
  }

  // 안 씀. 테스트를 위해 만들어 놓음.
  // lineBreakResult.formattedText의 높이를 textPainter로 계산하여, containerHeight보다 크면 마지막 줄부터 차례로 제거하여 허용되는 높이까지 줄이는 함수.
  LineBreakResult _reduceLinesToContainerHeight(
      String lines, List<int> breaks, double containerHeight, TextStyle style) {
    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(text: lines, style: style),
    );

    textPainter.layout(maxWidth: double.infinity);
    double textHeight = textPainter.height;

    // Keep removing lines until the text fits within the container height or no more lines can be removed
    while (textHeight > containerHeight && breaks.isNotEmpty) {
      // Remove the last line break
      breaks.removeLast();
      // Update the text by removing the last line
      String newText = lines.substring(0, breaks.isNotEmpty ? breaks.last : 0);
      // Measure the new text height
      textPainter.text = TextSpan(text: newText, style: style);
      textPainter.layout(maxWidth: double.infinity);
      textHeight = textPainter.height;
      lines = newText; // Update lines with the adjusted text
      print('textHeight: $textHeight');
    }

    return LineBreakResult(breaks, lines);
  }

  // 안 씀
  LineBreakResult _insertLineBreaks(String text, List<int> breakPositions) {
    List<String> charList = text.split('');
    List<int> adjustedBreakPositions = List<int>.from(breakPositions);
    int offset = 0;

    for (int i = 0; i < breakPositions.length; i++) {
      int breakIndex = breakPositions[i] + offset;
      if (breakIndex < charList.length) {
        charList.insert(breakIndex, '\n');
        offset++; // 다음 줄바꿈 위치 조정
        // 모든 이후의 줄바꿈 위치를 1씩 증가시켜 조정
        for (int j = i + 1; j < adjustedBreakPositions.length; j++) {
          adjustedBreakPositions[j] += 1;
        }
      }
    }

    return LineBreakResult(adjustedBreakPositions, charList.join(''));
  }

  // Expected: Input: "a bc" => Words: [a, bc]
  // Expected: Input: "a  bc  " => Words: [a, , , bc, , ]
  // Expected: Input: "a\tbc" => Words: [a,     , bc]
  // Expected: Input: "" => Words: [""]
  List<String> _splitTextIntoWordsAndSpaces(String input) {
    List<String> segments = [];
    StringBuffer currentSegment = StringBuffer();

    for (int i = 0, len = input.length; i < len; i++) {
      String char = input[i];

      if (char != ' ') {
        // 공백이 아닌 문자를 현재 세그먼트에 추가
        currentSegment.write(char);
      } else {
        // 현재 세그먼트가 비어있지 않다면, 세그먼트 목록에 추가하고 새로운 세그먼트 시작
        if (currentSegment.isNotEmpty) {
          segments.add(currentSegment.toString());
          currentSegment.clear();
        }
        // 공백 문자는 별도의 세그먼트로 처리
        segments.add(char);
      }
    }

    // 마지막 세그먼트가 남아 있다면 목록에 추가
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment.toString());
    }

    return segments;
  }

  // Replace each tab with a specified number of spaces
  LineBreakResult _replaceTabsWithSpaces(String input, List<int> previousBreaks,
      {int spacesPerTab = 4}) {
    List<int> adjustedBreakPositions = List<int>.from(previousBreaks);
    String spaces = List.filled(spacesPerTab, ' ').join('');
    StringBuffer adjustedText = StringBuffer();
    int offset = 0; // 탭 변환으로 인한 문자열 길이 조정을 추적하기 위한 오프셋

    for (int i = 0, len = input.length; i < len; i++) {
      if (input[i] == '\t') {
        // 탭 문자를 공백으로 변환
        adjustedText.write(spaces);
        // 탭으로 인해 문자열이 확장되었으므로, 오프셋 업데이트
        offset += spacesPerTab - 1;
        // 탭 이후의 모든 줄바꿈 위치를 오프셋만큼 조정
        adjustedBreakPositions = adjustedBreakPositions.map((pos) {
          return pos > i ? pos + offset : pos;
        }).toList();
      } else {
        // 탭이 아닌 문자는 그대로 추가
        adjustedText.write(input[i]);
      }
    }

    return LineBreakResult(adjustedBreakPositions, adjustedText.toString());
  }
}

class LineBreakResult {
  final List<int> breakPositions;
  final String formattedText;

  LineBreakResult(this.breakPositions, this.formattedText);
}

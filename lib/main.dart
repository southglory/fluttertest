import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart'; // Ensure GetX is still used for dependency injection.

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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TapController tapController = Get.put(TapController());

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
          onPanEnd: (DragEndDetails details) {
            // When the user stops dragging, notify the controller
            tapController.notifyEnd();

            if (tapController.start != null && tapController.end != null) {
              // Calculate the width and height of the rectangle
              final width =
              (tapController.end!.dx - tapController.start!.dx).abs();
              final height =
              (tapController.end!.dy - tapController.start!.dy).abs();
              // Navigate to the SquareDetailsScreen and pass the width and height as arguments
              Get.to(() => SquareDetailsScreen(width: width, height: height));
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
            ],
          ),
        ),
      ),
    );
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

  final double fontSizeDefault = 20;
  final FontWeight fontWeightDefault = FontWeight.bold;

  // Initialize textStyle using the default font size and weight
  late TextStyle textStyle;
  final TextAlign textAlignment = TextAlign.center;

  @override
  void initState() {
    super.initState();
    // Initialize textStyle here to use it in textChanged
    textStyle = TextStyle(
      fontSize: fontSizeDefault,
      fontWeight: fontWeightDefault,
      height: 1.0,
    );
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
                    // Capture the green container as an image
                    print('Capture the green container as an image');
                  },
                  // Text to display in the button and width, height of the green container
                  child:
                  Text('Capture Image, ${widget.width}x${widget.height}'),
                ),
              ],
            ),

            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.green,
              alignment: Alignment.center,
              child: Text(
                rareText, // Display the rare text here
                style: textStyle,
                textAlign: textAlignment,
              ),
            ),
            Divider(),
            Text(
              'Formatted Text:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              width: double.infinity,
              child: Text(formattedText, // Display the formatted text here
                  style: textStyle, textAlign: textAlignment),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child : LineBreaksTrackingTextField(
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
    required this.width, required this.height,
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
  _LineBreaksTrackingTextFieldState createState() => _LineBreaksTrackingTextFieldState();
}

class _LineBreaksTrackingTextFieldState extends State<LineBreaksTrackingTextField> {
  void _handleTextChange() {
    String text = widget.controller.text;

    String LoremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n"
        "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. \n"
        "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. \n"
        "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. ";
    // 여기서 사용자 입력 뒤에 "(LoremIpsum)"를 추가합니다.
    String rareText = "$text (${LoremIpsum})";

    // 현재 텍스트에서 수동 줄바꿈 위치 찾기
    List<int> manualBreaks = _findManualLineBreaks(rareText);

    // 최대 줄 수를 예상하고, 수동 줄바꿈에 의한 줄 수가 최대 줄 수를 넘어가지 않도록 rareText를 우선 제한. 자동 줄바꿈 계산 부하를 줄이기 위해 먼저 적용한 것.
    int maxLines = _getMaxLines(widget.height, widget.textStyle!);
    LineBreakResult maxLineBreakResult = restrictTextLines(rareText, manualBreaks, maxLines);

    // 내부적으로 자동 줄바꿈 위치를 추정하고, 줄바꿈을 삽입.
    LineBreakResult lineBreakResult = estimateAndInsertLineBreaks(
        maxLineBreakResult.formattedText, maxLineBreakResult.allBreaks, widget.textStyle!, widget.width);

    // 최종적으로 텍스트 필드에 표시할 줄바꿈되고 제한된 텍스트를 가져옴.
    LineBreakResult maxLineBreakResultFinal = restrictTextLines(
        lineBreakResult.formattedText, lineBreakResult.allBreaks, maxLines);

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
      maxLines: null, // 멀티라인 입력을 허용
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

  LineBreakResult estimateAndInsertLineBreaks(String text, List<int> manualBreaks, TextStyle textStyle, double containerWidth) {
    // Placeholder for estimating automatic line breaks. This should be replaced with your actual logic.
    List<int> autoBreaks = _estimateAutomaticLineBreaks(text, textStyle, containerWidth);

    // Inserting line breaks based on the estimated positions
    String formattedText = _insertLineBreaks(text, autoBreaks);

    return LineBreakResult(autoBreaks, formattedText);
  }

  List<int> _estimateAutomaticLineBreaks(String text, TextStyle textStyle, double containerWidth) {
    // 복잡한 로직 구현 필요
    return [];
  }

  int _findCutoffPosition(String text) {
    // 복잡한 로직 구현 필요
    // 글자 수 제한 기준: 특정 줄을 넘어가지 않도록 설정
    return text.length;
  }

  int _getMaxLines(double containerHeight, TextStyle style) {
    // 텍스트 페인터를 사용해서 텍스트가 특정 높이 내에 몇 줄이 들어갈 수 있는지 계산
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: ' ', style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity);
    // 텍스트가 들어갈 컨테이너에 높이 마진을 주어서 텍스트가 안전하게 들어갈 수 있도록 함
    double containerHeightWithMargin = containerHeight - style.fontSize! * style.height! * 0.5;
    print('fontSize: ${style.fontSize}');
    print('containerHeightWithMargin: $containerHeightWithMargin');
    int maxLines = (containerHeightWithMargin / textPainter.preferredLineHeight).floor();
    print('maxLines: $maxLines');
    return maxLines;
  }

  LineBreakResult restrictTextLines(String text, List<int> breakPositions, int maxLines) {
    List<int> adjustedBreakPositions = breakPositions;
    String adjustedText = text;
    if (breakPositions.length > maxLines) {
      // 최대 줄 수를 넘어가면, 줄바꿈 위치를 조정
      int cutoffPosition = breakPositions[maxLines - 1];
      adjustedBreakPositions = breakPositions.sublist(0, maxLines);
      adjustedText = text.substring(0, cutoffPosition);
    }
    print('adjustedBreakPositions: $adjustedBreakPositions');
    print('adjustedText: $adjustedText');
    // 조정된 줄바꿈 위치와 조정된 문자열을 포함하는 결과 반환
    return LineBreakResult(adjustedBreakPositions, adjustedText);
  }

  String _insertLineBreaks(String text, List<int> breakPositions) {
    List<String> charList = text.split('');
    for (int breakIndex in breakPositions.reversed) {
      if (breakIndex < charList.length) {
        charList.insert(breakIndex, '\n');
      }
    }
    return charList.join('');
  }
}

class LineBreakResult {
  final List<int> allBreaks;
  final String formattedText;

  LineBreakResult(this.allBreaks, this.formattedText);
}
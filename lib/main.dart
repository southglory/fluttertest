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
          onTapDown: (TapDownDetails details) {

          },
          onPanUpdate: (DragUpdateDetails details) {
            // Apply grid to the details.localPosition to make the drag coordinates snap to the grid
            final x = (details.localPosition.dx / 10).round() * 10;
            final y = (details.localPosition.dy / 10).round() * 10;
            // Keep updating the drag coordinates and the end position as the user drags
            tapController.updateDragCoordinates(Offset(x.toDouble(), y.toDouble()));
            tapController.updateEndingPoint(Offset(x.toDouble(), y.toDouble()));
          },
          onPanEnd: (DragEndDetails details) {
            // When the user stops dragging, notify the controller
            tapController.notifyEnd();

            if (tapController.start != null && tapController.end != null) {
              // Calculate the width and height of the rectangle
              final width = (tapController.end!.dx - tapController.start!.dx).abs();
              final height = (tapController.end!.dy - tapController.start!.dy).abs();
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
  String formattedText = ""; // State variable for holding formatted text
  int maxLength = 1; // State variable for holding the maximum length of the text

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

  @override
  void dispose() {
    _textController.removeListener(textChanged);
    _textController.dispose();
    super.dispose();
  }

  void textChanged() {
    final String currentText = _textController.text;
    // Format the text to fit the container
    TextBreaker textBreaker = TextBreaker(
      input: currentText, // Specify the input text
      textStyle: textStyle, // Specify the text style
      containerWidth: widget.width, // Specify container width
      containerHeight: widget.height, // Specify container height
      textAlign: textAlignment, // Specify text alignment
    );
    BreakTextResult result = textBreaker.breakCharacterWithMeasurement();
    formattedText = result.text;

    // Update the state to display formatted text
    setState(() {
      this.maxLength = formattedText.length> 0 ? formattedText.length - result.lineBreakCount : maxLength;
      this.formattedText = formattedText;
    });
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
                  child: Text('Capture Image, ${widget.width}x${widget.height}'),
                ),
              ],
            ),

            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.green,
              alignment: Alignment.center,
              child: Text(
                formattedText, // Display the formatted text here
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
              child: Text(formattedText, style: textStyle,textAlign: textAlignment),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                maxLength: maxLength,
                // To allow for unlimited lines, set maxLines to null.
                // If you want to limit the number of lines, set maxLines to an integer value greater than 1.
                maxLines: null,
                keyboardType: TextInputType.multiline, // Set the keyboard type to multiline
                textInputAction: TextInputAction.newline, // Set the input action to support newline for multiline input
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your comments',
                ),
                style: textStyle, // Apply the specified textStyle to the TextField
                // Optional: Remove the maxLength restriction while typing (but still show the counter)
                maxLengthEnforcement: MaxLengthEnforcement.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BreakTextResult {
  final String text;
  final int lineBreakCount;

  BreakTextResult(this.text, this.lineBreakCount);
}

class TextBreaker {
  final String input;
  final TextStyle textStyle;
  final double containerWidth;
  final double containerHeight;
  final TextAlign textAlign;

  TextBreaker({
    required this.input,
    required this.textStyle,
    required this.containerWidth,
    required this.containerHeight,
    this.textAlign = TextAlign.left,
  });

  BreakTextResult breakCharacterWithMeasurement() {
    List<String> lines = [];
    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
    );
    List<String> words = input.split(' '); // Split the input into words.
    String currentLine = '';
    double textWidth;
    double textWidthPadding = textStyle.fontSize! * 0.5;
    int linesCount = calculateLinesCount(textStyle, containerHeight);
    int currentLineCount = 0;

    print("containerWidth: $containerWidth");
    print("containerHeight: $containerHeight");

    for (String word in words) {
      // Handle each word
      bool isFirstCharacterOfWord = true;
      for (int i = 0; i < word.length; i++) {
        // Handle each character in the word
        String character = word[i];
        String testLine = isFirstCharacterOfWord && currentLine.isNotEmpty ? "$currentLine $character" : "$currentLine$character";
        textPainter.text = TextSpan(text: testLine, style: textStyle);
        textPainter.layout(maxWidth: double.infinity);

        textWidth = textPainter.width + textWidthPadding*2;
        if (textWidth > containerWidth) {
          if (!isFirstCharacterOfWord || currentLine.isNotEmpty) {
            // If the line is not empty, or if it's not the first character of the word, add the current line to the lines list
            lines.add(currentLine);
            currentLineCount++;
            if (currentLineCount >= linesCount) break; // Stop if the maximum number of lines is reached
            currentLine = character; // Start a new line with the current character
          } else {
            // If it's the first character of the word and the line is empty
            currentLine = character; // Add the character to the current line
          }
          isFirstCharacterOfWord = false;
        } else {
          // If the character fits, add it to the current line
          currentLine = testLine;
          isFirstCharacterOfWord = false;
        }
      }
      // After processing a word, add a space if it's not the end of a line
      if (currentLineCount < linesCount && !currentLine.endsWith(' ')) {
        currentLine += ' ';
      }

      // Check if we've reached the maximum number of lines
      if (currentLineCount >= linesCount) break;
    }

    // Add any remaining text in the currentLine to lines, if there's space
    if (!currentLine.isEmpty && currentLineCount < linesCount) {
      lines.add(currentLine.trim());
    }

    return BreakTextResult(lines.join('\n').trim(), lines.length-1);
  }

  int calculateLinesCount(TextStyle style, double containerHeight) {
    // Using a space character to measure the height might be more reliable as it should
    // give us the height of an empty line of text, including leading.
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: ' ', style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    // The height property acts as a multiplier to the font size.
    double styleHeight = style.fontSize! * (style.height ?? 1.0);
    // Measure the height of a space character as a proxy for line height.
    double measuredHeight = textPainter.size.height;
    print("measuredHeight: $measuredHeight");

    // Regard the line height as the maximum of the measured height and the style height.
    double lineHeight = measuredHeight > styleHeight ? measuredHeight : styleHeight;
    print("lineHeight: $lineHeight");

    // Calculate the number of lines that can fit in the container.
    int linesCount = containerHeight ~/ lineHeight;
    return linesCount;
  }
}


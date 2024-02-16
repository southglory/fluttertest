import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    TextAlign textAlign = TextAlign.left;
    double containerWidth = 300.0; // Example container width

    String inputText = "This is a sample text to demonstrate how we can format text "
        "based on container width and text style in Flutter. "
        "This particular string is designed to exceed the container width "
        "and demonstrate line breaking and clipping functionality.";

    // Use the new function
    String formattedText = breakCharacterWithMeasurement(inputText, textStyle, containerWidth, textAlign);
    print("Formatted Text: $formattedText");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Formatted Text Demo'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Container Width: $containerWidth',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Original Text:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  color: Colors.blueAccent.withOpacity(0.2),
                  width: containerWidth,
                  child: Text(inputText, style: textStyle, textAlign: textAlign),
                ),
                Divider(),
                Text(
                  'Formatted Text:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  // full width
                  width: double.infinity,
                  child: Text(formattedText, style: textStyle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String breakCharacterWithMeasurement(
    String input, TextStyle textStyle, double containerWidth, TextAlign textAlign) {
  List<List<int>> result = [];
  TextPainter textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: textAlign,
  );
  int startIndex = 0;
  String currentLine = "";

  for (int i = 0; i < input.length; i++) {
    String testLine = currentLine + input[i];
    textPainter.text = TextSpan(text: testLine, style: textStyle);
    textPainter.layout(maxWidth: double.infinity);

    if (textPainter.width > containerWidth && !currentLine.isEmpty) {
      result.add([startIndex, i - 1]);
      startIndex = i;
      currentLine = input[i];
    } else {
      currentLine = testLine;
    }
  }

  if (currentLine.isNotEmpty) {
    result.add([startIndex, input.length - 1]);
  }

  // Formatting result for demonstration
  return result.map((range) => input.substring(range[0], range[1] + 1)).join("\n");
}

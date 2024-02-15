import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Example text style and container width for demonstration
    TextStyle textStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    double containerWidth = 350.0; // Example container width

    // Sample long text input
    String inputText = "This is a sample text to demonstrate how we can format text "
        "based on container width and text style in Flutter. "
        "This particular string is designed to exceed the container width "
        "and demonstrate line breaking and clipping functionality.";

    // Format the text with measurement
    String formattedText = formatTextWithMeasurement(inputText, textStyle, containerWidth);
    print("Formatted Text: $formattedText");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Formatted Text Demo'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            // Display original and formatted text
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // show width
                Text(
                  'Container Width: $containerWidth',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Original text
                Text(
                  'Original Text:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  color: Colors.blueAccent.withOpacity(0.2),
                  width: containerWidth,
                  child: Text(inputText, style: textStyle),
                ),
                Divider(),
                // Formatted text
                Text(
                  'Formatted Text:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  width: containerWidth,
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

String formatTextWithMeasurement(String input, TextStyle textStyle, double containerWidth) {
  List<String> words = input.split(RegExp(r'\s+')); // Split input by any whitespace
  List<List<int>> result = []; // To store result as [[start, end]...]
  TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  int startIndex = 0; // Start index for each line
  String currentLine = "";

  for (int i = 0; i < words.length; i++) {
    String testLine = currentLine + (currentLine.isEmpty ? "" : " ") + words[i];
    textPainter.text = TextSpan(text: testLine, style: textStyle);
    textPainter.layout(maxWidth: double.infinity);

    if (textPainter.width > containerWidth && !currentLine.isEmpty) {
      // If current line width exceeds containerWidth, store indices and reset
      result.add([startIndex, i - 1]);
      startIndex = i; // Next line starts with current word
      currentLine = words[i]; // Reset currentLine to current word
    } else {
      currentLine = testLine; // Append word to current line
    }
  }

  // Add the last line if there's any content left
  if (currentLine.isNotEmpty) {
    result.add([startIndex, words.length - 1]);
  }

  print("Result: $result");
  // Formatting result for demonstration,
  return result.map((range) => "Words from ${range[0] + 1} to ${range[1] + 1}").join(", \n");
}

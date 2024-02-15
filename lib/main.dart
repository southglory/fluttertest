import 'package:flutter/material.dart';
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


class SquareDetailsScreen extends StatelessWidget {
  final double width;
  final double height;

  SquareDetailsScreen({Key? key, required this.width, required this.height})
      : super(key: key);

  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensure the keyboard does not cover the TextField
      appBar: AppBar(
        title: Text('Square Details'),
      ),
      body:  GestureDetector(
        onTap: () {
          // Dismiss the keyboard when the user taps outside of the TextField
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add a sizedBox
              SizedBox(height: 20),
              // Add a container to visualize the square
              Center(
                // Use a Container to visualize the square
                child: Container(
                  width: width,
                  height: height,
                  color: Colors.green, // Set the color of the container to green
                  alignment: Alignment.center,
                  child: Text(
                    // Reflects the text in the text field in real time.
                    _textController.text, // Use the controller's text as the content of the container
                    style: TextStyle(
                      color: Colors.white, // Ensure the text is readable on the green background
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Add a button to capture the above container as an image
              ElevatedButton(
                onPressed: () {
                  // Capture the container as an image
                  // ...
                },
                child: Text('Capture Image, size of width: $width, height: $height'),
              ),
              // Add a Multiline TextField
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _textController, // Use the controller to control the text field
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your comments',
                  ),
                  // Update the UI in real-time as the text changes
                  onChanged: (value) {
                    // Trigger a rebuild to update the text in the green container
                    (context as Element).markNeedsBuild();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


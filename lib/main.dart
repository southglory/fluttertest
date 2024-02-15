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
            // Keep updating the drag coordinates and the end position as the user drags
            tapController.updateDragCoordinates(details.localPosition);
            tapController.updateEndingPoint(details.localPosition); // 마지막 위치를 업데이트합니다.
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

  const SquareDetailsScreen({Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Square Details'),
      ),
      body: Center(
        child: Text('Width: $width, Height: $height'),
      ),
    );
  }
}

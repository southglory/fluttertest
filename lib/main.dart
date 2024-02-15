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

  void updateCoordinates(String newCoordinates) {
    startStr.value = newCoordinates;
  }

  void updateDetachmentCoordinates(Offset newCoordinates) {
    isDrawing = false;
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
  }
  void updateDragPoint(Offset newDrag) {
    dragStr.value = newDrag.toString();
    drag = newDrag;
  }
  void updateEndingPoint(Offset newEnd) {
    endStr.value = newEnd.toString();
    end = newEnd;
  }
}

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TapController tapController = Get.put(TapController());

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('GetX Dragging End Coordinates App'),
        ),
        body: GestureDetector(
          onTapDown: (TapDownDetails details) {
            // tapController.updateCoordinates(
            //   'Attach X: ${details.globalPosition.dx}, Y: ${details.globalPosition.dy}',
            // );
          },
          onPanUpdate: (DragUpdateDetails details) {
            // Keep updating the drag coordinates and the end position as the user drags
            tapController.updateDragCoordinates(details.globalPosition);
            tapController.updateEndingPoint(details.globalPosition); // 마지막 위치를 업데이트합니다.
          },
          onPanEnd: (DragEndDetails details) {
            // 이제 tapController.end는 null이 아니어야 합니다. 안전하게 ! 연산자를 사용할 수 있습니다.
            tapController.updateDetachmentCoordinates(tapController.end!);
          },

          child: Container(
            color: Colors.lightBlueAccent,
            alignment: Alignment.center,
            child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Start: ${tapController.startStr.value}"), // Starting coordinates
                SizedBox(height: 20), // Provide some spacing
                Text("Drag: ${tapController.dragStr.value}"), // Drag coordinates
                SizedBox(height: 20), // Provide some spacing
                Text("End: ${tapController.endStr.value}"), // Ending coordinates
              ],
            )),
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

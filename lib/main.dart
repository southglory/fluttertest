import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TapController extends GetxController {
  var coordinates = 'Tap Somewhere'.obs;
  var detachmentCoordinates = ''.obs;
  var dragCoordinates = ''.obs; // Add this line for drag coordinates

  void updateCoordinates(String newCoordinates) {
    coordinates.value = newCoordinates;
  }

  void updateDetachmentCoordinates(String newCoordinates) {
    detachmentCoordinates.value = newCoordinates;
  }

  // Add this method for updating drag coordinates
  void updateDragCoordinates(String newCoordinates) {
    dragCoordinates.value = newCoordinates;
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
            tapController.updateCoordinates(
              'Attach X: ${details.globalPosition.dx}, Y: ${details.globalPosition.dy}',
            );
          },
          onPanUpdate: (DragUpdateDetails details) {
            // Keep updating the drag coordinates as the user drags
            tapController.updateDragCoordinates(
              'Drag X: ${details.globalPosition.dx}, Y: ${details.globalPosition.dy}',
            );
          },
          onPanEnd: (DragEndDetails details) {
            // Use the last known drag position as the detachment coordinates
            tapController.updateDetachmentCoordinates(tapController.dragCoordinates.value);
          },
          child: Container(
            color: Colors.lightBlueAccent,
            alignment: Alignment.center,
            child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tapController.coordinates.value), // Attach coordinates
                SizedBox(height: 20), // Provide some spacing
                Text(tapController.detachmentCoordinates.value), // Detach (end of drag) coordinates
                SizedBox(height: 20), // Provide some spacing
                Text(tapController.dragCoordinates.value), // Continuous drag coordinates
              ],
            )),
          ),
        ),
      ),
    );
  }
}
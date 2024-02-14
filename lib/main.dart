import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TapController extends GetxController {
  var coordinates = 'Tap Somewhere'.obs;

  void updateCoordinates(String newCoordinates) {
    coordinates.value = newCoordinates;
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize your controller
    final TapController tapController = Get.put(TapController());

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('GetX Tap Coordinates App'),
        ),
        body: GestureDetector(
          onTapDown: (TapDownDetails details) {
            // Update the coordinates using the controller
            tapController.updateCoordinates(
              'X: ${details.globalPosition.dx}, Y: ${details.globalPosition.dy}',
            );
          },
          child: Container(
            color: Colors.blue, // To ensure GestureDetector is active
            alignment: Alignment.center,
            child: Obx(() => Text(tapController.coordinates.value)), // Use Obx to listen to changes
          ),
        ),
      ),
    );
  }
}

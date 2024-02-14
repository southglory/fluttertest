import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Ensure GetX is still used for dependency injection.

class TapController extends ValueNotifier<List<Offset>> {
  TapController() : super([]);

  void addPoint(Offset newPoint) {
    value.add(newPoint);
    notifyListeners();
  }

  void clearPoints() {
    value.clear();
    notifyListeners();
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
          title: Text('Dragging End Coordinates App'),
        ),
        body: GestureDetector(
          onTapDown: (TapDownDetails details) => tapController.addPoint(details.localPosition),
          onPanUpdate: (DragUpdateDetails details) => tapController.addPoint(details.localPosition),
          child: ValueListenableBuilder<List<Offset>>(
            valueListenable: tapController,
            builder: (context, points, child) {
              return CustomPaint(
                painter: CirclePainter(points: points),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final List<Offset> points;
  CirclePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    for (var point in points) {
      canvas.drawCircle(point, 10.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CirclePainter oldDelegate) => true;
}

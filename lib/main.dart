import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class SimpleController extends GetxController {
  int counter = 0;

  void increase() {
    counter++;
    update();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(SimpleController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("단순 상태관리"),
      ),
      body: Center(
        child: GetBuilder<SimpleController>(
          builder: (controller) {
            return ElevatedButton(
              child: Text(
                '현재 숫자: ${controller.counter}',
              ),
              onPressed: () {
                controller.increase();
              },
            );
          },
        ),
      ),
    );
  }
}

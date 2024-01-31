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

class ReactiveController extends GetxController {
  static ReactiveController get to => Get.find();
  RxInt counter = 0.obs;

  @override
  void onInit() {
    once(counter, (_) {
      print('once : $_이 처음으로 변경되었습니다.');
    });
    ever(counter, (_) {
      print('ever : $_이 변경되었습니다.');
    });
    debounce(
      counter,
          (_) {
        print('debounce : $_가 마지막으로 변경된 이후, 1초간 변경이 없습니다.');
      },
      time: Duration(seconds: 1),
    );
    interval(
      counter,
          (_) {
        print('interval $_가 변경되는 중입니다.(1초마다 호출)');
      },
      time: Duration(seconds: 1),
    );
    super.onInit();
  }


  void increase() {
    counter++;
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
  MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(SimpleController()); // 단순 상태 관리 controller 등록
    Get.put(ReactiveController()); // 반응형 상태 관리 controller 등록
    return Scaffold(
      appBar: AppBar(
        title: const Text("단순 / 반응형 상태관리"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GetBuilder<SimpleController>( // 단순 상태 관리
              builder: (controller) {
                return ElevatedButton(
                  child: Text(
                    '[단순]현재 숫자: ${controller.counter}',
                  ),
                  onPressed: () {
                    controller.increase();
                    // Get.find<SimpleController>().increase();
                  },
                );
              },
            ),
            GetX<ReactiveController>( // 반응형 상태관리 - 1
              builder: (controller) {
                return ElevatedButton(
                  child: Text(
                    '반응형 1 / 현재 숫자: ${controller.counter.value}', // .value 로 접근
                  ),
                  onPressed: () {
                    controller.increase();
                    // Get.find<ReactiveController>().increase();
                  },
                );
              },
            ),
            Obx( // 반응형 상태관리 - 2
                  () {
                return ElevatedButton(
                  child: Text(
                    '반응형 2 / 현재 숫자: ${Get.find<ReactiveController>().counter.value}', // .value 로 접근
                  ),
                  onPressed: () {
                    Get.find<ReactiveController>().increase();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

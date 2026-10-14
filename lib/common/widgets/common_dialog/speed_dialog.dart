import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future openSpeedDialog(double currentSpeed, ValueChanged<double> rateChange) async {
  var res = await Get.bottomSheet(ChooseSpeed(
    currentSpeed: currentSpeed,
    rateChange: rateChange,
  ));
  return res ?? false;
}

class ChooseSpeed extends StatelessWidget {
  static const speeds = [0.5, 0.75, 1.0, 1.25, 1.5];
  final double currentSpeed;
  ChooseSpeed({Key? key, required this.currentSpeed, required this.rateChange}) : super(key: key);
  final ValueChanged<double> rateChange;
  ScrollController controller = ScrollController();
  final ValueNotifier<double> selectValue = ValueNotifier<double>(1.0);
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 300), () {
      int initIndex = speeds.indexOf(currentSpeed);
      selectValue.value = currentSpeed;
      controller.jumpTo(initIndex * 42.0);
      controller.addListener(() {
        int curOffset = controller.offset ~/ 36;
        if (curOffset >= speeds.length) {
          return;
        }
        double currRate = speeds[curOffset];
        if (currRate != selectValue.value) {
          selectValue.value = currRate;
          rateChange(currRate);
        }
      });
    });
    return Container(
        padding: EdgeInsets.only(left: 0.w, right: 0.w, bottom: 0),
        decoration: ShapeDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8)))),
        child: Container(
            width: 1.sw,
            height: 0.5.sw,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
            ),
            child: ValueListenableBuilder(
                valueListenable: selectValue,
                builder: (BuildContext context, dynamic value, Widget? child) {
                  return scrollListView(controller);
                })));
  }

  Widget scrollListView(ScrollController controller) {
    return ListWheelScrollView(
      controller: controller,
      useMagnifier: true, // 启用放大镜效果
      magnification: 1.2, // 放大倍数
      itemExtent: 40.0, // 每个项目的高度
      children: speeds
          .map((e) => GestureDetector(
              onTap: () {},
              child: StatefulBuilder(builder: (context, state) {
                return Text("$e倍",
                    style: TextStyle(
                        fontSize: 18.sp,
                        color:
                            selectValue.value == e ? const Color(0xffC5ADFF) : const Color(0xff4e4e4e).withOpacity(0.5),
                        fontWeight: selectValue.value == e ? FontWeight.w900 : FontWeight.w400));
              })))
          .toList(),
    );
  }
}

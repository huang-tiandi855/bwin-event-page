import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/pages/home/home_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'channel_logic.dart';

class ChannelPage extends StatelessWidget {
  final logic = Get.put(ChannelLogic());
  final state = Get.find<ChannelLogic>().state;

  ChannelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(
        "我的频道",
      ),
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Padding(
          padding: EdgeInsets.only(left: 80.w, top: 100.w, right: 80.w),
          child: GridView.builder(
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, //横向数量
              crossAxisSpacing: 30.w, //间距
              mainAxisSpacing: 24.w, //行距
              childAspectRatio: 88.w / 88.w,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  int selectedIndex = index + 1;
                  switch (index) {
                    case 0:
                      Get.find<HomeLogic>()
                          .state
                          .tabController
                          .animateTo(selectedIndex);
                      break;
                    case 1:
                      Get.find<HomeLogic>()
                          .state
                          .tabController
                          .animateTo(selectedIndex);
                      break;
                    case 2:
                      Get.find<HomeLogic>()
                          .state
                          .tabController
                          .animateTo(selectedIndex);
                      break;
                    case 3:
                      Get.find<HomeLogic>()
                          .state
                          .tabController
                          .animateTo(selectedIndex + 1);
                      break;
                    case 4:
                      /*Get.find<HomeLogic>()
                          .state
                          .tabController
                          .animateTo(selectedIndex);*/

                      Get.find<HomeLogic>()
                          .state
                          .tabController
                          .animateTo(selectedIndex - 1);

                      break;
                    case 5:
                      Get.find<HomeLogic>()
                          .state
                          .tabController
                          .animateTo(selectedIndex);
                      break;
                    case 6:
                      Get.find<HomeLogic>()
                          .state
                          .tabController
                          .animateTo(selectedIndex);
                      break;
                    case 7:
                      Get.find<HomeLogic>()
                          .state
                          .tabController
                          .animateTo(selectedIndex);
                      break;
                    case 8:
                      Get.find<HomeLogic>()
                          .state
                          .tabController
                          .animateTo(selectedIndex);
                      break;
                  }

                  Get.back();
                },
                child: Image.asset(
                  state.lists[index],
                  width: 88.w,
                  height: 88.w,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

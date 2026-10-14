import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/customeIndicator.dart';
import '../../../../common/widgets/space_widget.dart';
import 'select_tag_logic.dart';

class SelectTagPage extends StatelessWidget {
  final logic = Get.find<SelectTagLogic>();
  final state = Get.find<SelectTagLogic>().state;

  SelectTagPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "话题列表",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 16.w, right: 16.w),
        child: Column(
          children: [
            getHeight(8),
            Container(
              alignment: Alignment.centerLeft,
              child: commonTabBar(
                TabBar(
                  isScrollable: true,
                  labelPadding: EdgeInsets.only(bottom: 3.w, right: 20.w),
                  indicatorPadding: EdgeInsets.only(right: 20.w),
                  controller: state.tabController,
                  tabs: state.tabs
                      .map(
                        (e) => Text(
                          e,
                        ),
                      )
                      .toList(),
                  labelColor: Colors.black,
                  labelStyle:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: TextStyle(fontSize: 18.w),
                  unselectedLabelColor: const Color.fromRGBO(159, 159, 175, 1),
                  indicator: const CustomerTabIndicator(
                    borderSide: BorderSide(color: Colors.white, width: 3),
                  ),
                  //indicatorWeight: ,
                  indicatorSize: TabBarIndicatorSize.label,
                ),
              ),
            ),
            getHeight(18),
            Expanded(
              child: TabBarView(
                controller: state.tabController,
                children: [
                  ListView.builder(
                    itemCount: 36,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.w),
                        child: Row(
                          children: [
                            CustomImage(
                              width: 72.w,
                              height: 72.w,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(36.r)),
                              url:
                                  'https://i.pinimg.com/originals/0b/75/7c/0b757c02ace9a69e1959f1ce6273b74b.jpg',
                              fit: BoxFit.cover,
                            ),
                            getWidth(12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "#萝幼院",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18.w),
                                ),
                                getHeight(6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "最新活动早知道…",
                                      style: TextStyle(
                                          color: const Color.fromRGBO(
                                              130, 127, 157, 1),
                                          fontSize: 15.w),
                                    ),
                                    getWidth(88.w),
                                    Image.asset(
                                      "assets/images/png/tag_unselected.png",
                                      width: 50.w,
                                      height: 25.w,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ListView.builder(
                    itemCount: 36,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.w),
                        child: Row(
                          children: [
                            CustomImage(
                              width: 72.w,
                              height: 72.w,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(36.r)),
                              url:
                                  'https://i.pinimg.com/originals/0b/75/7c/0b757c02ace9a69e1959f1ce6273b74b.jpg',
                              fit: BoxFit.cover,
                            ),
                            getWidth(12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "#萝幼院",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18.w),
                                ),
                                getHeight(6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "最新活动早知道…",
                                      style: TextStyle(
                                          color: const Color.fromRGBO(
                                              130, 127, 157, 1),
                                          fontSize: 15.w),
                                    ),
                                    getWidth(88.w),
                                    Image.asset(
                                      "assets/images/png/tag_unselected.png",
                                      width: 50.w,
                                      height: 25.w,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

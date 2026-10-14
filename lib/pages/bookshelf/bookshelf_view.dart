import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/tab_widgets/new_tabbar_view.dart';
import 'package:comics_app/pages/bookshelf/photo_item/photo_item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'banned_item/banned_item_view.dart';
import 'bookshelf_logic.dart';
import 'cartoon_item/cartoon_item_view.dart';
import 'comics_item/comics_item_view.dart';
import 'novel_item/novel_item_view.dart';
import 'real_person_item/real_person_item_view.dart';

class BookshelfPage extends StatelessWidget {
  const BookshelfPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final logic = Get.find<BookshelfLogic>();
    //final state = Get.find<BookshelfLogic>().state;

    final logic = Get.put(BookshelfLogic());
    final state = Get.find<BookshelfLogic>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text("我的收藏"),
        leading: commonBack(),
        //automaticallyImplyLeading: true,
        actions: [
          GestureDetector(
            onTap: () => logic.edit(),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(right: 12.w),
              child: Obx(() =>
                  Text(state.isEdit.value ? "清空" : '保存', style: TextStyle(fontSize: 15.sp, color: AppColor.c716f86))),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.w),
          child: Column(
            children: [
              SizedBox(
                height: 5.w,
              ),
              Container(
                height: 35.w,
                //margin: EdgeInsets.only(left: 14.w, right: 14.w),
                alignment: Alignment.centerLeft,
                child: FantasticTabBarView(
                  tabValues: state.tabValues,
                  isScrollable: false,
                  // tabAlignment: TabAlignment.center,
                  tabController: state.tabController,
                ),
                /*child: TabBar(
                  controller: state.tabController,
                  tabs: state.tabValues.map((f) {
                    return Text(f);
                  }).toList(),
                  indicatorColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.label,
                  //isScrollable: true,
                  labelColor: AppColor.bluishPurple,
                  labelStyle:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(fontSize: 15.sp),
                  unselectedLabelColor: AppColor.warmGrey,
                  labelPadding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  indicator: const RoundUnderlineTabIndicator(
                      borderSide:
                          BorderSide(color: AppColor.bluishPurple, width: 3)),
                ),*/
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: state.tabController,
        children: const [
          CartoonItemComponent(),
          ComicsItemComponent(),
          // CosItemComponent(),
          RealPersonItemComponent(),
          PhotoItemComponent(),
          NovelItemComponent(),
          BannedItemComponent(),
        ],
      ),
    );
  }
}

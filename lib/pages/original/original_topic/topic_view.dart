import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/pages/original/original_topic/topic_logic.dart';
import 'package:comics_app/pages/original/original_topic_detail/topic_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/values/widgetAttibutes/RoundUnderlineTablndicator.dart';
import '../../../common/widgets/common_ui/common_ui.dart';

class OriginalTopicPage extends StatelessWidget {
  OriginalTopicPage({Key? key}) : super(key: key);

  final logic = Get.find<OriginalTopicLogic>();
  final state = Get.find<OriginalTopicLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: commonAppBar(
          state.title,
        ),
        body: Container(
          color: const Color.fromRGBO(245, 245, 245, 1),
          child: Column(
            children: [
              Container(
                height: 48.w,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                alignment: Alignment.centerLeft,
                child: TabBar(
                  isScrollable: true,
                  indicatorPadding: EdgeInsets.only(top: 10.w),
                  controller: state.tabController,
                  tabs: state.tabs
                      .map(
                        (e) => Text(
                          e,
                        ),
                      )
                      .toList(),
                  labelColor: AppColor.bluishPurple,
                  labelStyle:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(fontSize: 15.sp),
                  unselectedLabelColor: AppColor.warmGrey,
                  labelPadding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 6),
                  indicator: const RoundUnderlineTabIndicator(
                      borderSide:
                          BorderSide(color: AppColor.bluishPurple, width: 6)),
                ),
              ),
              Expanded(
                  child: TabBarView(
                controller: state.tabController,
                children: const [
                  /// 1  最新 2  推荐 3  随机, 逛逛 4  热榜
                  OriginalTopicDetailPage(simpleSort: 1),
                  OriginalTopicDetailPage(simpleSort: 2),
                  OriginalTopicDetailPage(simpleSort: 3),
                  OriginalTopicDetailPage(simpleSort: 4),
                ],
              )),
            ],
          ),
        ));
  }
}

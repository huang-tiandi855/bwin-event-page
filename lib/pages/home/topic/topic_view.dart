import 'package:comics_app/common/widgets/tab_widgets/new_tabbar_view.dart';
import 'package:comics_app/pages/home/topic/topic_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/widgets/common_ui/common_ui.dart';
import '../topic_detail/topic_detail_view.dart';

class TopicPage extends StatelessWidget {
  TopicPage({Key? key}) : super(key: key);

  final logic = Get.find<TopicLogic>();
  final state = Get.find<TopicLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: commonAppBar(
          state.title,
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 20.w,
              ),
              child: FantasticTabBarView(
                tabValues: state.tabs,
                tabController: state.tabController,
              ),
            ),
            Expanded(
                child: TabBarView(
              controller: state.tabController,
              children: [
                /// 1  最新 2  最热
                TopicDetailPage(
                  simpleSort: 1,
                  zone: state.zone,
                  isJinGangZone: state.isJinGangQu,
                  isSkits: state.isSkits,
                ),
                TopicDetailPage(
                  simpleSort: 2,
                  zone: state.zone,
                  isJinGangZone: state.isJinGangQu,
                  isSkits: state.isSkits,
                ),
              ],
            )),
          ],
        ));
  }
}

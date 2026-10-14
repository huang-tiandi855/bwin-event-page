import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/style/location.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';
import '../widget/bookWidget.dart';
import 'novel_item_logic.dart';

class NovelItemComponent extends StatelessWidget {
  const NovelItemComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(NovelItemLogic());
    final state = Get.find<NovelItemLogic>().state;
    return Padding(
        padding: EdgeInsets.only(left: AppLocation.appHorizontal, right: AppLocation.appHorizontal, top: 10.w),
        child: PullRefreshView(
            onLoading: () => logic.onLoad(),
            onRefresh: () => logic.onRefresh(),
            retryOnTap: () => logic.onRefresh(),
            controller: state.pullRefreshController,
            child: CustomScrollView(slivers: <Widget>[
              GetBuilder<NovelItemLogic>(
                  id: "list",
                  builder: (logic) {
                    return sliverGrid3(state.list, isShowDelete: true, logic: logic, linkName: "书架-小说", kind: 4);
                  }),
              GetBuilder<NovelItemLogic>(
                  id: 'want',
                  builder: (logic) {
                    return state.wantToSeeList.isNotEmpty ? title() : const SliverToBoxAdapter();
                  }),
              GetBuilder<NovelItemLogic>(
                  id: 'want',
                  builder: (logic) {
                    return sliverGrid3(state.wantToSeeList, linkName: "书架-小说-猜你想看");
                  }),
            ])));
  }
}

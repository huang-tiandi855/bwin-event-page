import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/style/location.dart';
import '../widget/bookWidget.dart';
import 'comics_item_logic.dart';

class ComicsItemComponent extends StatelessWidget {
  const ComicsItemComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(ComicsItemLogic());
    final state = Get.find<ComicsItemLogic>().state;
    return Padding(
        padding: EdgeInsets.only(
            left: AppLocation.appHorizontal,
            right: AppLocation.appHorizontal,
            top: 10.w),
        child: PullRefreshView(
            onLoading: () => logic.onLoad(),
            onRefresh: () => logic.onRefresh(),
            retryOnTap: () => logic.onRefresh(),
            controller: state.pullRefreshController,
            child: CustomScrollView(slivers: <Widget>[
              GetBuilder<ComicsItemLogic>(
                  id: "list",
                  builder: (logic) {
                    return sliverGrid3(state.list,
                        isShowDelete: true, logic: logic,linkName: "书架-漫画");
                  }),
              GetBuilder<ComicsItemLogic>(
                  id: 'want',
                  builder: (logic) {
                    return state.wantToSeeList.isNotEmpty
                        ? title()
                        : const SliverToBoxAdapter();
                  }),
              GetBuilder<ComicsItemLogic>(
                  id: 'want',
                  builder: (logic) {
                    return sliverGrid3(state.wantToSeeList,linkName: "书架-漫画-猜你想看");
                  }),
            ])));
  }
}

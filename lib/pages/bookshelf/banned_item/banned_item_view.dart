import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/style/location.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';
import '../widget/bookWidget.dart';
import 'banned_item_logic.dart';

class BannedItemComponent extends StatelessWidget {
  const BannedItemComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(BannedItemLogic());
    final state = Get.find<BannedItemLogic>().state;
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
              GetBuilder<BannedItemLogic>(
                  id: "list",
                  builder: (logic) {
                    return sliverGrid3(state.list,
                        isShowDelete: true, logic: logic,linkName: "书架-原作");
                  }),
              GetBuilder<BannedItemLogic>(
                  id: 'want',
                  builder: (logic) {
                    return state.wantToSeeList.isNotEmpty
                        ? title()
                        : const SliverToBoxAdapter();
                  }),
              GetBuilder<BannedItemLogic>(
                  id: 'want',
                  builder: (logic) {
                    return sliverGrid3(state.wantToSeeList,linkName: "书架-原作-猜你想看");
                  }),
            ])));
  }
}

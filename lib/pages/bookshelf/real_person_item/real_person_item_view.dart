import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/style/location.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';
import '../widget/bookWidget.dart';
import 'real_person_item_logic.dart';

class RealPersonItemComponent extends StatelessWidget {
  const RealPersonItemComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(RealPersonItemLogic());
    final state = Get.find<RealPersonItemLogic>().state;
    return Padding(
        padding: EdgeInsets.only(left: AppLocation.appHorizontal, right: AppLocation.appHorizontal, top: 10.w),
        child: PullRefreshView(
            onLoading: () => logic.onLoad(),
            onRefresh: () => logic.onRefresh(),
            retryOnTap: () => logic.onRefresh(),
            controller: state.pullRefreshController,
            child: CustomScrollView(slivers: <Widget>[
              GetBuilder<RealPersonItemLogic>(
                  id: "list",
                  builder: (logic) {
                    return sliverVideoTypeGrid2(state.list, isShowDelete: true, logic: logic, linkName: "书架-真人");
                  }),
              GetBuilder<RealPersonItemLogic>(
                  id: 'want',
                  builder: (logic) {
                    return state.wantToSeeList.isNotEmpty ? title() : const SliverToBoxAdapter();
                  }),
              GetBuilder<RealPersonItemLogic>(
                  id: 'want',
                  builder: (logic) {
                    return sliverGrid2(state.wantToSeeList, linkName: "书架-真人-猜你想看");
                  }),
            ])));
  }
}

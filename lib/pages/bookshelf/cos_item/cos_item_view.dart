import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/style/location.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';
import '../widget/bookWidget.dart';
import 'cos_item_logic.dart';

class CosItemComponent extends StatelessWidget {
  const CosItemComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(CosItemLogic());
    final state = Get.find<CosItemLogic>().state;

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
              GetBuilder<CosItemLogic>(
                  id: "list",
                  builder: (logic) {
                    return sliverGrid2(state.list,
                        isShowDelete: true, logic: logic,linkName: "书架-COS");
                  }),
              title(),
              GetBuilder<CosItemLogic>(
                  id: 'want',
                  builder: (logic) {
                    return sliverGrid2(state.wantToSeeList,linkName: "书架-COS-猜你想看");
                  }),
            ])));
  }
}

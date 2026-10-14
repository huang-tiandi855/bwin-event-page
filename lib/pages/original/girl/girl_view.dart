import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/widgets/acg_section/acg_media_card.dart';
import '../../../common/widgets/acg_section/acg_media_grid_layout_view.dart';
import '../../../common/widgets/acg_section/acg_media_grid_view.dart';
import '../../../common/widgets/space_widget.dart';
import '../abs_origin_view.dart';
import 'girl_logic.dart';

class GirlPage extends AbsOriginListView<GirlLogic> {
  String id;
  GirlPage({required this.id,Key? key}) : super(key: key);

  @override
  GirlLogic createController() {
    return Get.put(GirlLogic(id: id),tag: obtainTag());
  }

  @override
  createListBody(GirlLogic controller) {
    return CustomScrollView(slivers: [
      SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          var item =  controller.state.dataList[index];
          return Column(
            children: [
              if (item.showType != 1) ...[
                20.verticalSpace,
                getTitle(item,hPadding: 10.w),
              ],
              MediaGridLayoutView(showType: item.showType, medias: item.allMediaInfo,isOriginModule: true,)
            ],
          );
        }, childCount: controller.state.dataList.length),
      ),
      MediaGridView.sliver(
        padding: EdgeInsets.only(top: 9.w,left: 10.w,right: 10.w),
        crossAxisCount: 2,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 9.w,
        aspectRatio: 173 / 304,
        itemBuilder: (p0, index) {
          final e = controller.state.mediaList[index];
          return MediaCard.fromVideoModel(
            e,
            forceVerticalCover: true,
            index: index,
          );
        },
        itemCount: controller.state.mediaList.length,
      ),

    ]);
  }

  @override
  String obtainTag() {
   return 'GirlLogic';
  }
}

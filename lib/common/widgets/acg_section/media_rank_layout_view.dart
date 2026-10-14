import 'package:comics_app/common/entities/module_detail_model/all_media_rank_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../style/color.dart';
import 'acg_media_grid_layout_view.dart';

class MediaRankLayoutView extends StatelessWidget {
  TabController rankTabController;
  List<AllMediaRankModel> allRankInfo;
  final ValueNotifier<int> selectIndex = ValueNotifier<int>(0);
  MediaRankLayoutView({required this.rankTabController, required this.allRankInfo, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [createTabView(), 12.verticalSpace, createTabBody()],
    );
  }

  Widget createTabView() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.w),
      alignment: Alignment.centerLeft,
      child: TabBar(
        controller: rankTabController,
        tabs: allRankInfo.map((f) {
          return Text(f.name ?? "");
        }).toList(),
        labelPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        isScrollable: false,
        labelColor: AppColor.c555555,
        indicatorSize: TabBarIndicatorSize.tab,
        unselectedLabelColor: AppColor.c999999,
        unselectedLabelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppColor.c999999),
        indicator: BoxDecoration(
            color: Colors.white,
            gradient:
                const LinearGradient(colors: [Color.fromRGBO(0, 0, 0, 0.05), Color.fromRGBO(141, 141, 141, 0.05)]),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xff8D8D8D).withOpacity(0.1), width: 2)),
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppColor.c555555),
        onTap: (index) {
          selectIndex.value = index;
        },
      ),
    );
  }

  Widget createTabBody() {
    return ValueListenableBuilder(
        valueListenable: selectIndex,
        builder: (_, __, ___) {
          return MediaGridLayoutView(
              showType: 27,
              medias: allRankInfo[selectIndex.value].allMediaInfo ?? [],
              padding: EdgeInsets.only(left: 12.w, right: 12.w));
        });
  }
}

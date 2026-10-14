import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/widgets/acg_section/acg_media_grid_layout_view.dart';
import 'package:comics_app/pages/home/tag_detail/tag_detail_state.dart';
import 'package:comics_app/pages/home/tag_detail/tag_sub/tag_sub_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/pullRefreshView/pull_refresh_view.dart';

class TagSubDetailWidget extends StatelessWidget {
  TagSubDetailWidget({super.key, this.title, this.id, this.kind, this.sortType, this.isSubTabView = false});
  String? title;
  String? id;
  int? kind;
  int? sortType;
  bool isSubTabView;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TagSubDetailLogic>(
        init: TagSubDetailLogic(title: title, id: id, kind: kind, sortType: sortType, isSubTabView: isSubTabView),
        tag: key.toString(),
        builder: (logic) {
          var state = logic.state;
          return createBody(logic, state);
        });
  }

  Widget createBody(TagSubDetailLogic logic, TagDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: PullRefreshView(
          key: key,
          controller: state.pullRefreshController,
          onRefresh: () {
            state.pageNum = 1;
            logic.doInit();
          },
          onLoading: () {
            state.pageNum += 1;
            logic.doInit();
          },
          retryOnTap: () {
            state.pageNum = 1;
            logic.doInit();
          },
          child: MediaGridLayoutView(
            showType: state.isSubVerticalCover ? 2 : 5,
            medias: state.realTagSubMediaList,
            onItemTap: (index) {
              var item = state.realTagSubMediaList[index];
              if(item.isAd){
                AppNavigator.to.jumpAdv(url: item.adUrl, planId: '', slotCode: '');
                return;
              }
              AppNavigator.to.jumpDetails(item.kind, item.id ?? "", modelList: state.realTagSubMediaList, isOff: true);
            },
          )),
    );
  }

}

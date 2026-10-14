import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/tab_widgets/new_tabbar_view.dart';
import 'package:comics_app/pages/home/tag_detail/tag_detail_logic.dart';
import 'package:comics_app/pages/home/tag_detail/tag_detail_state.dart';
import 'package:comics_app/pages/home/tag_detail/tag_sub/tag_sub_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/keep_alive_widget.dart';

class TagSubDetailPage extends StatelessWidget {
  TagSubDetailPage({
    super.key,
    this.title,
    this.id,
    this.kind,
  });
  String? title;
  String? id;
  int? kind;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TagDetailLogic>(
        init: TagDetailLogic(title: title, id: id, kind: kind),
        tag: key?.toString()??"TagDetailSpecialLogic-$id-$kind-$title",
        builder: (logic) {
          var state = logic.state;
          return Scaffold(
              appBar: commonAppBar(
                state.title,
              ),
              body: createTagBody(state));
        });
  }

  createTagBody(TagDetailState state) {
    return Column(
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
              /// 排序类型 1:最多观看,2:最多收藏,3:最新上架
              KeepAliveWidget(
                TagSubDetailWidget(
                  id: state.id,
                  kind: state.kind,
                  sortType: 0,
                  key: ValueKey("$kind$title=0=>${state.id}"),
                ),
              ),
              KeepAliveWidget(
                TagSubDetailWidget(
                  id: state.id,
                  kind: state.kind,
                  sortType: 1,
                  key: ValueKey("$kind$title=1=>${state.id}"),
                ),
              ),
              KeepAliveWidget(
                TagSubDetailWidget(
                  id: state.id,
                  kind: state.kind,
                  sortType: 2,
                  key: ValueKey("$kind$title=2=>${state.id}"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

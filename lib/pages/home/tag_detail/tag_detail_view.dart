import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/const.dart';
import 'package:comics_app/common/widgets/CustomLoadingWidget.dart';
import 'package:comics_app/common/widgets/acg_section/acg_media_grid_layout_view.dart';
import 'package:comics_app/common/widgets/tab_widgets/new_tabbar_view.dart';
import 'package:comics_app/pages/home/tag_detail/tag_detail_logic.dart';
import 'package:comics_app/pages/home/tag_detail/tag_detail_state.dart';
import 'package:comics_app/pages/common/mine/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/routers/app_routes.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';

class TagDetailPage extends StatelessWidget {
  TagDetailPage({
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
        tag: key?.toString() ?? "TagDetailLogic-$id-$title-$kind",
        builder: (logic) {
          var state = logic.state;
          return createBody(logic, state);
        });
  }

  Widget createBody(TagDetailLogic logic, TagDetailState state) {
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
          child: CustomScrollView(
            slivers: [
              if (state.tagMediaList.isNotEmpty)
                SliverList(
                    delegate: SliverChildListDelegate([
                  GetBuilder<TagDetailLogic>(
                      init: logic,
                      id: "tagList",
                      builder: (logic) {
                        return staggeredMediaList(state.tagMediaList,
                            showLightKey: state.title);
                      }),
                  Container(
                    width: 1.sw,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.TAGS_DETAIL, arguments: {
                            "title": state.title,
                            "tags": state.tagsId?.join(","),
                            "kind": state.kind,
                            "isSub": true,
                          });
                        },
                        child: const Text(
                          "查看更多",
                          style:
                              TextStyle(fontSize: 12, color: AppColor.c999999),
                        )),
                  )
                ])),
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.w,
                  ),
                  child: FantasticTabBarView(
                    tabValues: state.tabs,
                    tabController: state.tabController,
                  ),
                ),
              ),
              if (state.mediaList.isNotEmpty)
                SliverList(
                    delegate: SliverChildListDelegate([
                  GetBuilder<TagDetailLogic>(
                      init: logic,
                      id: "mediaList",
                      builder: (logic) {
                        return state.isLoading
                            ? CustomerLoadingWidget()
                            : state.kind == KindConst.PORTRAYKIND
                                ? staggeredMediaList(state.mediaList)
                                : MediaGridLayoutView(
                                    showType: state.isVerticalCover ? 6 : 5,
                                    medias: state.mediaList
                                        .map((e) => AllMediaInfoModel.fromJson(
                                            e.toJson()))
                                        .toList());
                      })
                ]))
            ],
          )),
    );
  }
}

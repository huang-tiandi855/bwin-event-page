import 'package:comics_app/common/widgets/community_style.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/item/home_video_list_widgets.dart';
import 'package:comics_app/common/widgets/item/meida_cover_item.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../widgets/search_filter_label_row.dart';
import 'logic.dart';

class SearchVideoLibraryPage extends StatelessWidget {
  const SearchVideoLibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchVideoLibraryLogic>(
      init: SearchVideoLibraryLogic(),
      builder: (logic) {
        final state = logic.state;
        final pullRefresh = state.pullRefreshController;
        final videoType = state.types[state.typeIndex].id ?? 0;
        final bool isPost = logic.isPostType;
        final items = state.videoItems;
        final postItems = state.postItems;
        final bool isEmpty = isPost ? postItems.isEmpty : items.isEmpty;
        final String emptyText = isPost ? '暂无相关帖子' : '暂无相关视频';

        return getBgColorsView(
          child: ExtendedNestedScrollView(
            onlyOneScrollInBody: true,
            headerSliverBuilder: (context, inner) {
              return [
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SearchFilterLabelRow(
                          title: '分类',
                          options: state.types,
                          selectedIndex: state.typeIndex,
                          onSelected: logic.selectType,
                        ),
                        // 标签筛选两类都开：视频走 `getVodTagsList` 自带的视频
                        // 类标签；帖子复用同一份选项，命中标签时把 `tag` 透传
                        // 给 [CircleApi.getPostingList] 的 `keyword` 做关键字
                        // 筛选（_getPostData 内已串好）。
                        if (state.tagOptions.isNotEmpty)
                          SearchFilterLabelRow(
                            title: '标签',
                            options: state.tagOptions,
                            selectedIndex: state.tagIndex,
                            onSelected: logic.selectTag,
                          ),
                        // 「类型」（VIP / 金币）只针对视频维度的付费区分；帖子
                        // 接口虽然也支持 `costType`，但产品规则要求选中「帖子」
                        // 时整行隐藏，避免和标签筛选叠加产生空结果。
                        if (!isPost)
                          SearchFilterLabelRow(
                            title: '类型',
                            options: state.payTypes,
                            selectedIndex: state.payIndex,
                            onSelected: logic.selectPayType,
                          ),
                        SearchFilterLabelRow(
                          title: '排序',
                          options: state.sorts,
                          selectedIndex: state.sortIndex,
                          onSelected: logic.selectSort,
                        ),
                      ],
                    ),
                  ),
                ),
                // SliverToBoxAdapter(child: SizedBox(height: 18.w)),
              ];
            },
            body: PullRefreshView(
              controller: pullRefresh,
              onRefresh: logic.onRefresh,
              onLoading: logic.onLoad,
              retryOnTap: logic.onRefresh,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  if (isEmpty &&
                      pullRefresh.requestCode != PULL_REQUEST_CODE.REQUESTING)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 160.w,
                        child: Center(
                          child: Text(
                            emptyText,
                            style: TextStyle(
                              color: Colors.white.withOpacity(.45),
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (isPost && postItems.isNotEmpty)
                    // 「帖子」分类参考社区帖子模块版式：纵向 PostCard 列表。
                    getPostListStyle(
                      items: postItems,
                      isSliver: true,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    )
                  else if (!isPost && items.isNotEmpty)
                    getFourGrid(
                      items,
                      sliver: true,
                      sliverPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      displayType: videoType == 1
                          ? MediaCoverDisplayType.shortvideo
                          : MediaCoverDisplayType.landscape,
                      // 「抖音」分类（videoType == 1）走沉浸式短视频列表播放；
                      // 其余分类沿用 getFourGrid 默认的 jumpMediaPlay 长视频播放。
                      onItemClick: videoType == 1
                          ? logic.navigateToShortPlay
                          : null,
                    ),
                  SliverToBoxAdapter(child: SizedBox(height: 12.w)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

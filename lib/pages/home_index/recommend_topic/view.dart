import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/utils/ads_manage/ads_banner_widget.dart';
import 'package:comics_app/common/utils/ads_manage/ads_grid_view_widget.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/item/home_topic_widget.dart';
import 'package:comics_app/common/widgets/marquee_widget/marquee_widget.dart';
import 'package:comics_app/pages/loading/loading_center_widget.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'state.dart';

/// 一级 Tab「专题」：Banner + 跑马灯 + icon 网格 + 专题列表（整体 Sliver）。
class RecommendTopicPage extends StatefulWidget {
  const RecommendTopicPage({
    Key? key,
    required this.module,
    required this.uniqueTag,
  }) : super(key: key);

  final String uniqueTag;
  final ModuleModel module;

  @override
  State<RecommendTopicPage> createState() => _RecommendTopicPageState();
}

class _RecommendTopicPageState extends State<RecommendTopicPage> {
  late final RecommendTopicState state;
  RecommendTopicLogic get logic =>
      Get.find<RecommendTopicLogic>(tag: widget.uniqueTag);

  @override
  void initState() {
    super.initState();
    Get.put(RecommendTopicLogic(module: widget.module), tag: widget.uniqueTag);
    state = logic.state;
  }

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    return GetBuilder<RecommendTopicLogic>(
      tag: widget.uniqueTag,
      builder: (_) {
        return getBgColorsView(
          child: ExtendedNestedScrollView(
            onlyOneScrollInBody: true,
            headerSliverBuilder: (context, inner) {
              return [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 5.w, 16.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (module.isShowBanner) ...[
                          _buildBanner(),
                          // SizedBox(height: state.afterBannerGap.h),
                        ],
                        if (module.isShowNotice) ...[
                          const NoticeMarqueeBar(
                            margin: EdgeInsets.only(bottom: 16),
                            showType: NoticeShowType.home,
                            showCloseButton: true,
                          ),
                          // SizedBox(height: state.afterMarqueeGap.h),
                        ],
                        if (module.isShowIcon) _buildIconGrid(),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: _buildBody(),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (state.isTopicMediaLoading) {
      return const LoadingCenterWidget();
    }

    if (state.isTopicMediaEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: getEmptyWidget(emptyText: '暂无数据'),
          ),
        ],
      );
    }

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext c, int index) {
              final TopicListItem item = state.topicListItems[index];
              return getTopicWidget(item.topic, item.mediaList);
            },
            childCount: state.topicListItems.length,
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return const AdsBannerWidget(
        padding: EdgeInsets.only(bottom: 16), adsType: AdsType.banner);
  }

  Widget _buildIconGrid() {
    return const AdsGridViewWidget(
      adsType: AdsType.dbLineHead,
      isBigStyle: true,
      padding: EdgeInsets.only(bottom: 5),
    );
  }
}

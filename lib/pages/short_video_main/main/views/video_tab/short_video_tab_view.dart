import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/widgets/item/home_video_list_widgets.dart';
import 'package:comics_app/common/widgets/item/meida_cover_item.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'short_video_tab_logic.dart';
import 'short_video_tab_state.dart';

class ShortVideoTabView extends StatelessWidget {
  const ShortVideoTabView({
    super.key,
    required this.module,
    this.moduleSort,
    this.padding,
  });

  final ModuleModel module;

  final int? moduleSort;

  String get id => module.id!.toString();

  final EdgeInsets? padding;

  String get tag => '${id}_$moduleSort';

  ShortVideoTabLogic get logic => Get.find(tag: tag);
  ShortVideoTabState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    Get.put(
      ShortVideoTabLogic(module: module, moduleSort: moduleSort),
      tag: tag,
    );
    return PullRefreshView(
      controller: state.pullRefreshController,
      onRefresh: logic.onRefresh,
      onLoading: logic.onLoad,
      retryOnTap: logic.onRefresh,
      child: CustomScrollView(
        slivers: [
          GetBuilder<ShortVideoTabLogic>(
            tag: tag,
            id: 'list',
            builder: (_) {
              return getFourGrid(state.mediaList ?? [],
                  sliver: true,
                  sliverPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  onItemClick: (index) {
                logic.navigateToPlayPage(index);
              }, displayType: MediaCoverDisplayType.shortvideo);
            },
          ),
        ],
      ),
    );
  }
}

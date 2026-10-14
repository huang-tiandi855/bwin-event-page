import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/widgets/item/home_topic_widget.dart';
import 'package:comics_app/common/widgets/selection_check_badge.dart';
import 'package:comics_app/common/widgets/item/meida_cover_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 四宫格 showType = 2,8
Widget getFourGrid(List<MediaVideoModel> mediaList,
    {bool sliver = false,
    ValueChanged<int>? onItemClick,
    MediaCoverDisplayType? displayType,
    EdgeInsetsGeometry? sliverPadding,
    EdgeInsetsGeometry? margin}) {
  return sliver
      ? SliverPadding(
          padding: sliverPadding ?? EdgeInsets.zero,
          sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, //横向数量
                  crossAxisSpacing:
                      displayType == MediaCoverDisplayType.shortvideo
                          ? 11.w
                          : 13.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio:
                      displayType == MediaCoverDisplayType.shortvideo
                          ? 166 / 301
                          : 165 / 155),
              delegate: SliverChildBuilderDelegate((c, index) {
                var media = mediaList[index];
                return MediaCoverItem(
                  model: media,
                  onTap: () => onItemClick != null
                      ? onItemClick.call(index)
                      : jumpMediaPlayByModel(
                          media,
                          mediaList: mediaList,
                          index: index,
                        ),
                  displayType: displayType ?? MediaCoverDisplayType.landscape,
                );
              }, childCount: mediaList.length)))
      : Container(
          margin: margin ?? EdgeInsets.only(bottom: 15.h),
          child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, //横向数量
                  crossAxisSpacing:
                      displayType == MediaCoverDisplayType.shortvideo
                          ? 11.w
                          : 13.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio:
                      displayType == MediaCoverDisplayType.shortvideo
                          ? 166 / 301
                          : 165 / 159),
              itemCount: mediaList.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                var media = mediaList[index];
                return MediaCoverItem(
                  model: media,
                  onTap: () => onItemClick != null
                      ? onItemClick.call(index)
                      : jumpMediaPlayByModel(
                          media,
                          mediaList: mediaList,
                          index: index,
                        ),
                  displayType: displayType ?? MediaCoverDisplayType.landscape,
                );
              }));
}

/// 在 [getFourGrid] 相同版式上增加多选角标（不修改原方法实现）。
Widget getFourGridWithSelection(
  List<MediaVideoModel> mediaList, {
  bool sliver = false,
  MediaCoverDisplayType? displayType,
  EdgeInsetsGeometry? sliverPadding,
  required bool selectionMode,
  required Set<int> selectedIndices,
  ValueChanged<int>? onToggleSelection,
  ValueChanged<int>? onItemClickWhenInactive,
}) {
  final dt = displayType ?? MediaCoverDisplayType.landscape;
  final crossAxisSpacing = dt == MediaCoverDisplayType.shortvideo ? 11.w : 13.w;
  final mainAxisSpacing = 12.h;
  final childAspectRatioSliver =
      dt == MediaCoverDisplayType.shortvideo ? 166 / 305 : 165 / 157;
  final childAspectRatioBox =
      dt == MediaCoverDisplayType.shortvideo ? 166 / 305 : 165 / 157;

  Widget cell(int index) {
    final media = mediaList[index];
    final selected = selectedIndices.contains(index);
    final inner = MediaCoverItem(
      model: media,
      onTap: () {
        if (selectionMode) {
          onToggleSelection?.call(index);
        } else if (onItemClickWhenInactive != null) {
          onItemClickWhenInactive.call(index);
        } else {
          jumpMediaPlayByModel(
            media,
            mediaList: mediaList,
            index: index,
          );
        }
      },
      displayType: dt,
    );
    return wrapWithSelectionCheckBadge(
      child: inner,
      selectionMode: selectionMode,
      selected: selected,
    );
  }

  if (sliver) {
    return SliverPadding(
      padding: sliverPadding ?? EdgeInsets.zero,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatioSliver,
        ),
        delegate: SliverChildBuilderDelegate(
          (c, index) => cell(index),
          childCount: mediaList.length,
        ),
      ),
    );
  }

  return Container(
    margin: EdgeInsets.only(bottom: 15.h),
    child: GridView.builder(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatioBox,
      ),
      itemCount: mediaList.length,
      shrinkWrap: true,
      itemBuilder: (context, index) => cell(index),
    ),
  );
}

/// 大列表 showType = 3
Widget getBigColumn(List<MediaVideoModel> mediaList,
    {bool sliver = false,
    ValueChanged<int>? onItemClick,
    EdgeInsetsGeometry? sliverPadding}) {
  return sliver
      ? SliverPadding(
          padding: sliverPadding ??
              EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 15.h),
          sliver: SliverList(
              delegate: SliverChildBuilderDelegate((c, index) {
            var media = mediaList[index];
            return Column(children: [
              MediaCoverItem(
                model: media,
                onTap: () => onItemClick != null
                    ? onItemClick.call(index)
                    : jumpMediaPlayByModel(
                        media,
                        mediaList: mediaList,
                        index: index,
                      ),
                displayType: MediaCoverDisplayType.list,
              ),
              12.h.verticalSpace,
            ]);
          }, childCount: mediaList.length)))
      : Container(
          margin: EdgeInsets.only(bottom: 15.h),
          child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: mediaList.length,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (BuildContext context, int index) {
                return 12.h.verticalSpace;
              },
              itemBuilder: (BuildContext context, int index) {
                var media = mediaList[index];
                return MediaCoverItem(
                  model: media,
                  onTap: () => onItemClick != null
                      ? onItemClick.call(index)
                      : jumpMediaPlayByModel(
                          media,
                          mediaList: mediaList,
                          index: index,
                        ),
                  displayType: MediaCoverDisplayType.list,
                );
              }));
}

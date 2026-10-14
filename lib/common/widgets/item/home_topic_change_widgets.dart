import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/item/home_topic_widget.dart';
import 'package:comics_app/common/widgets/item/meida_cover_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 换一换
Widget changeWidget({VoidCallback? onMore, VoidCallback? onChange}) {
  return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    getCommonButton('',
        width: 168.w,
        height: 43.h,
        radius: 2.5.r,
        onClick: onMore,
        color: const Color(0xFFF9F9F9),
        textStyle: TextStyle(fontSize: 14.sp)),
    7.w.horizontalSpace,
    getCommonButton('',
        width: 168.w,
        height: 43.h,
        radius: 2.5.r,
        color: const Color(0xFFF9F9F9),
        onClick: onChange,
        textStyle: TextStyle(fontSize: 14.sp)),
  ]);
}

/// 大列表(换一换) showType = 1
class GetLargeChangeList extends StatefulWidget {
  final ValueChanged<int>? onItemClick;
  final List<MediaVideoModel> mediaList;

  const GetLargeChangeList({
    Key? key,
    this.onItemClick,
    required this.mediaList,
  }) : super(key: key);

  @override
  State<GetLargeChangeList> createState() => _GetLargeChangeListState();
}

class _GetLargeChangeListState extends State<GetLargeChangeList> {
  /// 换一换
  onChange() async {}

  /// 看更多
  onSeeMore() {}

  @override
  Widget build(BuildContext context) {
    final List<MediaVideoModel> list = widget.mediaList;
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: list.length > 10 ? 10 : list.length,
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (BuildContext context, int index) {
              return 12.h.verticalSpace;
            },
            itemBuilder: (BuildContext context, int index) {
              var media = list[index];
              return MediaCoverItem(
                model: media,
                onTap: () => widget.onItemClick != null
                    ? widget.onItemClick?.call(index)
                    : jumpMediaPlayByModel(
                        media,
                        mediaList: list,
                        index: index,
                      ),
                displayType: MediaCoverDisplayType.list,
              );
            }),
        // changeWidget(onMore: () => onSeeMore(), onChange: () => onChange())
      ],
    );
  }
}

/// 横排排版(换一换) showType = 1
class GetHorizontalChangeLayoutList extends StatefulWidget {
  final MediaCoverDisplayType displayType;
  final ValueChanged<int>? onItemClick;
  final List<MediaVideoModel> mediaList;

  const GetHorizontalChangeLayoutList({
    Key? key,
    this.onItemClick,
    required this.mediaList,
    required this.displayType,
  }) : super(key: key);

  @override
  State<GetHorizontalChangeLayoutList> createState() =>
      _GetHorizontalChangeLayoutListState();
}

class _GetHorizontalChangeLayoutListState
    extends State<GetHorizontalChangeLayoutList> {
  /// 换一换
  onChange() async {}

  /// 看更多
  onSeeMore() {}

  /// 每种 [MediaCoverDisplayType] 在水平列表中的 **item 宽度**。
  ///
  /// 水平 [ListView] 的子 item 在主轴方向是 unbounded，必须给 [MediaCoverItem]
  /// 显式宽度，否则其内部的 [AspectRatio] 同时拿到 unbounded 宽 / 高约束会抛
  /// `RenderAspectRatio has unbounded constraints` 异常。
  ///
  /// 取值与设计稿保持一致（与 [_listBoxHeight] 同源宽度像素）：
  /// - bighorizontallist：300 × 169
  /// - smallhorizontallist：167 × 93
  /// - smallverticallist：134 × 178（封面区高 178，整卡含标题/底栏更高，由
  ///   [_listBoxHeight] 适配；如有溢出后续再调）
  double _itemWidth(MediaCoverDisplayType type) {
    switch (type) {
      case MediaCoverDisplayType.bighorizontallist:
        return 300.w;
      case MediaCoverDisplayType.smallhorizontallist:
        return 167.w;
      case MediaCoverDisplayType.smallverticallist:
        return 134.w;
      default:
        return 134.w;
    }
  }

  /// 整行 [SizedBox] 的高度。需要把封面 + 标题 + 底栏全部包进来，否则会发生
  /// 子 item 高度溢出（hasSize / overflow）。封面图高度已知，再额外预留
  /// 文案 + 间距区域：
  /// - 标题最多 2 行（`landscape` 才 2 行，其余 1 行），按 12sp × 1.35 行高 ≈ 17，
  ///   再加上下间距 4 + 1 ≈ 5；
  /// - 底栏一行 ≈ 18；
  /// - 留少量缓冲。
  double _listBoxHeight(MediaCoverDisplayType type) {
    switch (type) {
      case MediaCoverDisplayType.bighorizontallist:
        return 169.h + 34.h; // 169 封面 + 标题2行 + 底栏
      case MediaCoverDisplayType.smallhorizontallist:
        return 93.h + 34.h;
      case MediaCoverDisplayType.smallverticallist:
        return 178.h + 34.h; // 178 封面 + 标题1行 + 底栏
      default:
        return 178.h + 34.h;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<MediaVideoModel> list = widget.mediaList;
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }
    final double listBoxH = _listBoxHeight(widget.displayType);
    final double itemW = _itemWidth(widget.displayType);
    return Column(
      children: [
        SizedBox(
          height: listBoxH,
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: list.length > 10 ? 10 : list.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) {
              return 10.w.horizontalSpace;
            },
            itemBuilder: (BuildContext context, int index) {
              var media = list[index];
              return SizedBox(
                width: itemW,
                child: MediaCoverItem(
                  model: media,
                  displayType: widget.displayType,
                  onTap: () => widget.onItemClick != null
                      ? widget.onItemClick?.call(index)
                      : jumpMediaPlayByModel(
                          media,
                          mediaList: list,
                          index: index,
                        ),
                ),
              );
            },
          ),
        ),
        // changeWidget(onMore: () => onSeeMore(), onChange: () => onChange())
      ],
    );
  }
}

/// 五宫格(换一换) showType = 1 — 首条大图使用 [MediaCoverItem]（与列表同竖向卡片样式）。
class GetFiveChangeGrid extends StatefulWidget {
  final ValueChanged<int>? onItemClick;
  final List<MediaVideoModel> mediaList;

  const GetFiveChangeGrid({
    Key? key,
    this.onItemClick,
    required this.mediaList,
  }) : super(key: key);

  @override
  State<GetFiveChangeGrid> createState() => _GetFiveChangeGridState();
}

class _GetFiveChangeGridState extends State<GetFiveChangeGrid> {
  /// 换一换
  onChange() async {}

  /// 看更多
  onSeeMore() {}

  @override
  Widget build(BuildContext context) {
    final List<MediaVideoModel> list = widget.mediaList;
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }
    final MediaVideoModel big = list.first;
    final List<MediaVideoModel> sub =
        list.length > 1 ? list.sublist(1) : <MediaVideoModel>[];
    return Column(children: [
      MediaCoverItem(
        model: big,
        onTap: () => widget.onItemClick?.call(0),
        displayType: MediaCoverDisplayType.list,
      ),
      GridView.builder(
          shrinkWrap: true,
          itemCount: sub.length > 4 ? 4 : sub.length,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(top: 12.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, //横向数量
              crossAxisSpacing: 13.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 165 / 159),
          itemBuilder: (BuildContext context, int index) {
            return MediaCoverItem(
              model: sub[index],
              onTap: () => widget.onItemClick?.call(index + 1),
              displayType: MediaCoverDisplayType.landscape,
            );
          }),
      // changeWidget(onMore: () => onSeeMore(), onChange: () => onChange())
    ]);
  }
}

/// 四宫格,六宫格(换一换) showType = 2,8
class GetFourChangeGrid extends StatefulWidget {
  final int count;
  final ValueChanged<int>? onItemClick;
  final List<MediaVideoModel> mediaList;
  const GetFourChangeGrid({
    Key? key,
    this.count = 4,
    this.onItemClick,
    required this.mediaList,
  }) : super(key: key);

  @override
  State<GetFourChangeGrid> createState() => _GetFourChangeGridState();
}

class _GetFourChangeGridState extends State<GetFourChangeGrid> {
  /// 换一换
  onChange() async {}

  /// 看更多
  onSeeMore() {}

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GridView.builder(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, //横向数量
              crossAxisSpacing: 13.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 165 / 159),
          itemCount: widget.mediaList.length > widget.count
              ? widget.count
              : widget.mediaList.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            var media = widget.mediaList[index];
            return MediaCoverItem(
              model: media,
              onTap: () => widget.onItemClick?.call(index),
              displayType: MediaCoverDisplayType.landscape,
            );
          }),
      // changeWidget(onMore: () => onSeeMore(), onChange: () => onChange())
    ]);
  }
}

/// 动漫 竖版6宫格/9宫格(换一换) showType = 6,7
class GetShortChangeGrid extends StatefulWidget {
  final int count;
  final ValueChanged<int>? onItemClick;
  final List<MediaVideoModel> mediaList;

  const GetShortChangeGrid({
    Key? key,
    this.count = 6,
    this.onItemClick,
    required this.mediaList,
  }) : super(key: key);

  @override
  State<GetShortChangeGrid> createState() => _GetShortChangeGridState();
}

class _GetShortChangeGridState extends State<GetShortChangeGrid> {
  /// 换一换
  onChange() async {}

  /// 看更多
  onSeeMore() {}

  @override
  Widget build(BuildContext context) {
    final List<MediaVideoModel> list = widget.mediaList;
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(children: [
      GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemCount: list.length > widget.count ? widget.count : list.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, //横向数量
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 108 / 190),
          itemBuilder: (BuildContext context, int index) {
            return MediaCoverItem(
              model: list[index],
              onTap: () => widget.onItemClick?.call(index),
              displayType: MediaCoverDisplayType.portrait,
            );
          }),
      // changeWidget(onMore: () => onSeeMore(), onChange: () => onChange())
    ]);
  }
}

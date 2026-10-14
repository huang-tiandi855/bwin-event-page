import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/entities/pagination_model.dart';
import 'package:comics_app/common/entities/video_model/tags_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/utils/short_media_util.dart';
import 'package:comics_app/common/widgets/item/home_topic_change_widgets.dart';
import 'package:comics_app/common/widgets/item/meida_cover_item.dart';
import 'package:comics_app/common/widgets/item/topic_more_title_item.dart';
import 'package:comics_app/pages/home_index/topic_more_detail/topic_more_detail_route.dart';
import 'package:comics_app/pages/short_video_main/play/short_video_play_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'home_video_list_widgets.dart';

/// 获取topic的item
Widget getTopicWidget(ModuleModel groups, List<MediaVideoModel> mediaList,
    {ValueChanged<int>? onItemClick,
    VoidCallback? onTitleClick,
    bool showMore = true}) {
  void defaultPlay(int index) {
    if (index < 0 || index >= mediaList.length) return;
    // 把当前列表 + index 一并传入：短视频走 [ShortVideoPlayPage] 时可以在
    // 已有列表内继续上下滑（参考 [ShortVideoTabLogic.navigateToPlayPage]）。
    jumpMediaPlayByModel(
      mediaList[index],
      mediaList: mediaList,
      index: index,
    );
  }

  final ValueChanged<int> itemClick = onItemClick ?? defaultPlay;

  /// 与 [GetFiveChangeGrid]/[GetFourChangeGrid]/[GetShortChangeGrid] 注释中的 `showType` 对齐；
  final int? showType = groups.guildType;
  final Widget child;
  if (showType == 0) {
    /// 大列表
    child = GetLargeChangeList(
      mediaList: mediaList,
      onItemClick: itemClick,
    );
  } else if (showType == 1) {
    /// 大横排
    child = GetHorizontalChangeLayoutList(
      mediaList: mediaList,
      onItemClick: itemClick,
      displayType: MediaCoverDisplayType.bighorizontallist,
    );
  } else if (showType == 2) {
    /// 小横排 竖版
    child = GetHorizontalChangeLayoutList(
      mediaList: mediaList,
      onItemClick: itemClick,
      displayType: MediaCoverDisplayType.smallverticallist,
    );
  } else if (showType == 3) {
    /// 四宫格
    child = GetFourChangeGrid(
      mediaList: mediaList,
      onItemClick: itemClick,
    );
  } else if (showType == 4) {
    /// 五宫格
    child = GetFiveChangeGrid(
      mediaList: mediaList,
      onItemClick: itemClick,
    );
  } else if (showType == 5) {
    /// 六宫格 竖版
    child = GetShortChangeGrid(
      mediaList: mediaList,
      onItemClick: itemClick,
    );
  } else if (showType == 6) {
    /// 六宫格 横版
    child = GetFourChangeGrid(
      count: 6,
      mediaList: mediaList,
      onItemClick: itemClick,
    );
  } else if (showType == 7) {
    /// 九宫格 竖版
    child = GetShortChangeGrid(
      count: 9,
      mediaList: mediaList,
      onItemClick: itemClick,
    );
  } else {
    child = getFourGrid(
        mediaList.length > 4 ? mediaList.sublist(0, 4) : mediaList,
        sliver: false,
        sliverPadding: EdgeInsets.symmetric(horizontal: 16.w),
        margin: EdgeInsets.zero,
        onItemClick: itemClick,
        displayType: MediaCoverDisplayType.shortvideo);
  }

  return Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      TopicMoreTitleItem(
        title: groups.groupName ?? "",
        showMore: showMore,
        onMoreTap: () {
          // 走 [TopicMoreDetailRoute.push]：内部生成唯一 tag 写进
          // `Get.arguments`，[TopicMoreDetailBinding] 据此为本次 push 注册
          // 一份独立的 logic 实例，栈上多份 TopicMoreDetail 互不影响。
          TopicMoreDetailRoute.push(
            topicId: groups.id,
            topicName: groups.groupName ?? '',
            videoType: groups.videoType,
          );
        },
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: child,
      ),
    ]),
  );
}

/// 跳转到长视频详情页 [AppRoutes.VIDEO_PAGE]。
///
/// 调用方拿到视频 id 后传入即可，空 id 直接 short-circuit。短视频对应版本见
/// [jumpShortMediaPlay] / [jumpShortMediaPlayBySingleId]；如果手上是
/// [MediaVideoModel] 而不只是 id，建议用 [jumpMediaPlayByModel]，自动按
/// `videoType` 路由短 / 长视频。
void jumpMediaPlay(String videoId) {
  if (videoId.isEmpty) return;
  Get.toNamed(
    AppRoutes.VIDEO_PAGE,
    arguments: {'id': videoId},
  );
}

/// 跳转到短视频「垂直滑动播放页」 [ShortVideoPlayPage]（**列表场景的统一入口**）。
///
/// 实现完全参考 [ShortVideoTabLogic.navigateToPlayPage]：把当前列表整体转成
/// [VideoModel]，附带 `initialIndex` 与可选的分页 [videoProvider]，进入页面
/// 后即可在已加载的列表内上下滑动，并按需懒加载更多。
///
/// 入参：
/// - [mediaList]：当前列表，必须非空且 [index] 合法；
/// - [index]：当前点击的位置；
/// - [videoProvider]：可选分页 provider，用于上滑触底时加载下一页；不传则
///   仅能在 [mediaList] 范围内滑动。
///
/// 业务侧的标准写法是在列表 item 的 `onTap` 里直接调用本方法（或更高层的
/// [jumpMediaPlayByModel] 自动路由），不必在每个列表逻辑里复制
/// `Get.to(() => ShortVideoPlayPage(...))` 这套样板。
void jumpShortMediaPlay({
  required List<MediaVideoModel> mediaList,
  required int index,
  Future<PaginationModel<VideoModel>> Function()? videoProvider,
}) {
  if (mediaList.isEmpty) return;
  if (index < 0 || index >= mediaList.length) return;
  Get.to(
    () => ShortVideoPlayPage(
      videoProvider: videoProvider,
      initialIndex: index,
      initialList: mediaList.map(videoModelFromHomeMedia).toList(),
    ),
  );
}

/// 单 id 短视频跳转（**深链 / 历史记录 / 头像点击 等"单条"入口**）。
///
/// 与 [jumpShortMediaPlay] 的区别：
/// - 这里走的是 [ShortMediaUtil.jumpBySingleMediaId] → [ShortMediaPlayPage]
///   旧的"按视频 id 找到/进入对应短剧组合"路径，会读本地观看记录恢复
///   `selectIndex`；
/// - 列表场景请优先用 [jumpShortMediaPlay]（list + index 版本）。
void jumpShortMediaPlayBySingleId(String videoId) {
  if (videoId.isEmpty) return;
  ShortMediaUtil.jumpBySingleMediaId(videoId);
}

/// 根据 [MediaVideoModel.videoType] 自动选择「长视频」或「短视频」的跳转入口。
///
/// `videoType`（与 home 列表请求参数同源）：
/// - 0：普通长视频 → [jumpMediaPlay]；
/// - 1：短视频流 → [jumpShortMediaPlay]（list + index 入 [ShortVideoPlayPage]）；
/// - 2：暗网视频 → 仍按长视频详情页处理（沿用现网行为）；
/// - null / 其他 → fallback 到长视频。
///
/// 调用方拿到 [MediaVideoModel] 时统一调本方法即可：
/// - 仅传单个 [media]：短视频会以 `[media]` 作为单条列表跳到 [ShortVideoPlayPage]
///   （此时无法上下滑切集，但符合"列表外的单条入口"语义）；
/// - 传 [mediaList] + [index]：短视频会以整个列表跳进去，可上下滑动；
/// - 传 [videoProvider]：列表底部到达时自动懒加载，与
///   [ShortVideoTabLogic._videoProvider] 行为一致。
void jumpMediaPlayByModel(
  MediaVideoModel media, {
  List<MediaVideoModel>? mediaList,
  int? index,
  Future<PaginationModel<VideoModel>> Function()? videoProvider,
}) {
  final String? id = media.id;
  if (id == null || id.isEmpty) return;
  if (media.videoType == 1) {
    final List<MediaVideoModel> list =
        (mediaList != null && mediaList.isNotEmpty)
            ? mediaList
            : <MediaVideoModel>[media];
    final int idx = (mediaList != null && index != null) ? index : 0;
    jumpShortMediaPlay(
      mediaList: list,
      index: idx,
      videoProvider: videoProvider,
    );
    return;
  }
  jumpMediaPlay(id);
}

/// 把首页 / 列表的 [MediaVideoModel] 适配成短视频流使用的 [VideoModel]。
///
/// 与 [ShortVideoTabLogic._videoFromHomeMedia] 的实现保持一致，集中放在
/// 这里供所有"短视频跳转"入口复用，避免每个 logic 自己再实现一遍封面 /
/// gold / tags / freeArea 等字段的拼装。
VideoModel videoModelFromHomeMedia(MediaVideoModel model) {
  final picInfo = model.vodPicInfo;
  final String? verticalCover = _pickNonEmpty([
    model.vodPic,
    picInfo?.verticalLarge,
    picInfo?.verticalSmall,
  ]);
  final String? cover = _pickNonEmpty([
    picInfo?.horizontalLarge,
    picInfo?.horizontalSmall,
    verticalCover,
  ]);
  final int gold = _toInt(model.gold) ?? 0;
  return VideoModel(
    id: model.id,
    newsType: 'SP',
    title: model.title,
    sourceUrl: model.vodSerialNumber?.toString(),
    playTime: model.vodDuration,
    cover: cover,
    verticalCover: verticalCover,
    playCount: model.readNumber,
    coins: gold,
    originCoins: gold,
    freeArea: !model.isVip && gold <= 0,
    isRecommend: (model.recommend ?? 0) > 0,
    tags: _parseTagsForVideoModel(model.tags),
  );
}

String? _pickNonEmpty(List<String?> values) {
  for (final value in values) {
    final text = value?.trim();
    if (text != null && text.isNotEmpty) return text;
  }
  return null;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

List<TagsModel> _parseTagsForVideoModel(dynamic raw) {
  if (raw == null) return const [];
  if (raw is String) {
    final name = raw.trim();
    if (name.isEmpty) return const [];
    return [
      TagsModel.fromJson({'name': name})
    ];
  }
  if (raw is! List) return const [];
  return raw.map((item) {
    if (item is Map) {
      return TagsModel.fromJson(Map<String, dynamic>.from(item));
    }
    return TagsModel.fromJson({'name': item.toString()});
  }).toList();
}

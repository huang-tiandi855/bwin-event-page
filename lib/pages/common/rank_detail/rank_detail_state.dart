import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';

/// 排行榜列表项封面形态（与一级 Tab 对应）。
enum RankDetailThumbLayout {
  /// 横版 16:9 类（影片）
  landscape,

  /// 竖版海报类（动漫、漫画等）
  portrait,
}

class RankDetailState {
  static const List<String> primaryTabs = [
    '影片',
    '抖音',
    '帖子',
    // '漫画',
    // '图集',
  ];

  static const List<String> periodLabels = ['日榜', '周榜', '月榜', '总榜'];

  /// 分页条数（与接口 `pageSize` 一致）。
  static const int rankListPageSize = 20;

  /// 接口 `rankDataType`：与「日 / 周 / 月 / 总」一一对应（若与后端不一致，仅改此处映射）。
  static const List<int> filmPeriodRankDataTypes = [1, 3, 5];
  static const List<int> animePeriodRankDataTypes = [0, 1, 2, 3];

  /// 日、周、月、总共 4 套下拉刷新（影片 / 动漫共用；同时只挂载在当前一级 Tab 下的列表，避免重复绑定）。
  final List<PullRefreshController> rankPeriodPullRefreshControllers =
      List.generate(
    periodLabels.length,
    (int i) => PullRefreshController(isRequest: i == 0),
  );

  /// 影片榜：按周期下标存列表。
  final List<List<MediaVideoModel>> filmRankLists =
      List.generate(periodLabels.length, (_) => <MediaVideoModel>[]);

  /// 动漫榜：按周期下标存列表。
  final List<List<MediaVideoModel>> animeRankLists =
      List.generate(periodLabels.length, (_) => <MediaVideoModel>[]);

  /// 下一请求页码（与 [RecommendNewState] 一致：`onRefresh` 置 1，`onLoad` 先自增再请求）。
  final List<int> filmRankPage = List.filled(periodLabels.length, 1);
  final List<int> animeRankPage = List.filled(periodLabels.length, 1);

  /// 与 [primaryTabs] 下标对应
  static const List<RankDetailThumbLayout> thumbLayouts = [
    RankDetailThumbLayout.landscape,
    RankDetailThumbLayout.portrait,
    RankDetailThumbLayout.portrait,
    RankDetailThumbLayout.portrait,
    RankDetailThumbLayout.landscape,
  ];

  static const String kPlaceholderCover =
      'https://i.pinimg.com/originals/0b/75/7c/0b757c02ace9a69e1959f1ce6273b74b.jpg';

  /// 卡片背景（略亮于 scaffold）
  static const Color cardBackground = Color(0xFF141920);
}

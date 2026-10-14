import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/video_model/short_recommend_follow_model.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class ShortVideoSkitsFollowTabState {
  ShortVideoSkitsFollowTabState();

  final PullRefreshController pullRefreshController = PullRefreshController();

  // ---------------------------------------------------------------------------
  // 关注列表（cms/vod/search-follows）。
  // ---------------------------------------------------------------------------

  /// 关注作者的短视频聚合列表。`null` 表示首屏还没拉到结果（与「空数组 = 无关注」
  /// 严格区分）。
  List<MediaVideoModel>? mediaList;

  int pageNumber = 1;

  static const int pageSize = 10;

  // ---------------------------------------------------------------------------
  // 推荐关注列表（cms/vod/authors/videos）。
  // 仅在 [mediaList] 拉回为空时展示，作者卡片点关注成功会触发 [mediaList] 刷新。
  // ---------------------------------------------------------------------------

  /// 推荐作者列表。业务侧不分页，每次下拉刷新拿全量。
  List<ShortRecommendFollowItemModel> recommendList = const [];

  /// 是否处于「显示推荐作者」模式：
  /// - 首屏 / 下拉刷新后关注列表为空时置 true；
  /// - 推荐位的关注操作触发关注列表刷新，若关注列表回来有数据 → 置 false。
  bool isShowRecommend = false;

  /// 正在请求关注接口的作者 uid，用于按钮防抖 + 局部 update。
  final Set<int> pendingFollowUids = <int>{};
}

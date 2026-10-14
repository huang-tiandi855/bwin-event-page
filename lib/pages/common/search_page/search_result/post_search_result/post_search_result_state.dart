import 'package:comics_app/common/widgets/post_card/post_card.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class PostSearchResultState {
  /// 当前搜索关键字；空 / 空白会被 logic 规范化为 `null`。
  String? keyWord;

  /// 下拉刷新 / 上拉加载控制器。
  late PullRefreshController pullRefreshController = PullRefreshController();

  /// 当前页码，从 1 开始。
  int pageNum = 1;

  /// 是否还有下一页；首屏 / 刷新前先乐观置 true，由接口返回的 `hasNextPage`
  /// 收敛。`false` 后再调 [PostSearchResultLogic.onLoadMore] 会直接短路。
  bool hasMore = true;

  /// 当前页累计的帖子卡片数据。
  List<PostCardData> postCardList = [];

  PostSearchResultState();
}

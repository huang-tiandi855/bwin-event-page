import 'package:comics_app/common/widgets/post_card/post_card.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:get/get.dart';

/// 创作中心三 Tab（已发布 / 待审核 / 未通过）共享状态。
///
/// 每个 Tab 独立维护：分页页码、是否还有下一页、当前帖子列表、
/// 拉新 / 加载更多状态机（[PullRefreshController]）以及是否已发起过首屏请求。
class CreateCenterState {
  /// 帖子创作收益余额
  double posting = 0.0;

  /// 帖子创作累计收益
  double postingSum = 0.0;

  /// 初始选中 Tab，由路由参数 `index` 决定。
  int index = 0;

  /// Tab → 后端 `status` 值的映射（与 [tabLabels] / [tabCount] 对齐）。
  ///
  /// 后端约定：0 审核中 / 1 审核通过 / 2 审核失败 / 3 下架 / 4 创建失败。
  static const List<int> tabStatusValues = <int>[1, 0, 2];

  /// Tab 标题，同时用作 `PostCard.statusLabelOverride` 的角标文案。
  static const List<String> tabLabels = <String>['已发布', '待审核', '未通过'];

  static int get tabCount => tabLabels.length;

  /// 每个 Tab 当前已加载到的页码（从 1 开始）。
  final List<int> pages =
      List<int>.filled(tabCount, 1, growable: false);

  /// 每个 Tab 当前是否还有下一页。
  final List<bool> hasMore =
      List<bool>.filled(tabCount, true, growable: false);

  /// 每个 Tab 的当前帖子列表。
  final List<List<PostCardData>> posts = List<List<PostCardData>>.generate(
    tabCount,
    (_) => <PostCardData>[],
    growable: false,
  );

  /// 每个 Tab 的下拉刷新 / 上拉加载控制器；首次构造默认 `REQUESTING` 态，
  /// 触发首屏请求时不需要额外切换 loading。
  late final List<PullRefreshController> pullControllers;

  /// 每个 Tab 是否已发起过首屏请求；切换 Tab 时按需懒加载，避免重复请求。
  final List<bool> loaded =
      List<bool>.filled(tabCount, false, growable: true);

  CreateCenterState() {
    final dynamic raw = Get.arguments?['index'];
    if (raw is int) {
      index = raw.clamp(0, tabCount - 1);
    }
    pullControllers = List<PullRefreshController>.generate(
      tabCount,
      (_) => PullRefreshController(),
      growable: false,
    );
  }

  /// 页面销毁时统一释放底层 `RefreshController` / `ValueNotifier`。
  void dispose() {
    for (final PullRefreshController c in pullControllers) {
      c.dispose();
    }
  }
}

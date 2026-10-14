import 'package:comics_app/common/entities/home/hot_tag_models.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecommendColumnBannerKingKongTagState {
  /// 二级 Tab（本模块独立）
  late List<String> secondaryTabs;

  int secondaryTabIndex = 0;

  bool secondaryVideoGridLayout = true;

  /// 每个二级 Tab 一份**独立**的视频列表，索引与 [secondaryTabs] 对齐。
  ///
  /// 之前所有 tab 共用一份 [secondaryVideoItems]，切 tab 时旁边那一页会
  /// 先看到当前 tab 数据再被新数据替换；改为每个 tab 各自一份后，切 tab
  /// 之间互不影响。
  late List<List<MediaVideoModel>> tabVideoItems;

  /// 每个二级 Tab 独立的当前页码，索引与 [secondaryTabs] 对齐。
  late List<int> tabPageNumbers;

  /// 每个二级 Tab 是否已经成功加载过首屏（切 tab 时判定是否触发首拉）。
  late List<bool> tabLoaded;

  /// 仅「无 sub tabs」回退分支使用；有 sub tabs 时 logic 按 tabIndex 现算。
  int sortType = 1;

  final int pageSize = 20;

  final PullRefreshController pullRefreshController = PullRefreshController();

  late final List<PullRefreshController> tabPullRefreshControllers;

  /// 当前 tab 的视频列表（按 [secondaryTabIndex] 路由）。
  /// 兼容旧调用方；新代码直接走 [tabVideoItems]。
  List<MediaVideoModel> get secondaryVideoItems => tabVideoItems.isEmpty
      ? const <MediaVideoModel>[]
      : tabVideoItems[secondaryTabIndex.clamp(0, tabVideoItems.length - 1)];
  set secondaryVideoItems(List<MediaVideoModel> value) {
    if (tabVideoItems.isEmpty) return;
    tabVideoItems[secondaryTabIndex.clamp(0, tabVideoItems.length - 1)] = value;
  }

  /// 当前 tab 的页码（兼容旧调用方；新代码直接走 [tabPageNumbers]）。
  int get pageNumber => tabPageNumbers.isEmpty
      ? 1
      : tabPageNumbers[secondaryTabIndex.clamp(0, tabPageNumbers.length - 1)];
  set pageNumber(int value) {
    if (tabPageNumbers.isEmpty) return;
    tabPageNumbers[secondaryTabIndex.clamp(0, tabPageNumbers.length - 1)] =
        value;
  }

  PullRefreshController get activeBodyPullRefresh =>
      tabPullRefreshControllers.isEmpty
          ? pullRefreshController
          : tabPullRefreshControllers[
              secondaryTabIndex.clamp(0, tabPullRefreshControllers.length - 1)];

  /// 各分组 [HotTagGroupModel.tagList] 按接口顺序拼接后的展示列表。
  final RxList<ModuleModel> hotTags = <ModuleModel>[].obs;

  final RxBool hotTagsExpanded = false.obs;

  static const int collapsedGridSlots = 16;
  static const int collapsedTagSlots = 15;

  final String hotTagExpandLabel = '展开';
  final String hotTagCollapseLabel = '收起';

  Color get hotTagCellBg => Colors.white.withOpacity(.05);

  RecommendColumnBannerKingKongTagState() {
    secondaryTabs = [
      '热门推荐',
      '最新上架',
      '最多观看',
      '最多收藏',
    ];
    final int n = secondaryTabs.length;
    // 即便回退到「无 sub tabs」分支也至少留一个槽位，让 [pageNumber] /
    // [secondaryVideoItems] / [pullRefreshController] 老路径继续可用。
    final int slot = n == 0 ? 1 : n;
    tabVideoItems = List.generate(slot, (_) => <MediaVideoModel>[]);
    tabPageNumbers = List.filled(slot, 1);
    tabLoaded = List.filled(slot, false);
    tabPullRefreshControllers = n == 0
        ? <PullRefreshController>[]
        : List.generate(
            n,
            (i) => PullRefreshController(isRequest: i == 0),
          );
  }
}

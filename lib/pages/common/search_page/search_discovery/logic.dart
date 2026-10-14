import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:get/get.dart';

import '../search_page_logic.dart';
import 'state.dart';

class SearchDiscoveryLogic extends GetxController {
  final SearchDiscoveryState state = SearchDiscoveryState();
  late final SearchPageLogic parentLogic;
  late final void Function() _searchTextListener;

  static const int rankPageSize = 8;

  @override
  void onInit() {
    super.onInit();
    parentLogic = Get.find<SearchPageLogic>();
    _searchTextListener = () {
      final text = parentLogic.state.textEditingController.text.trim();
      if (text.isEmpty && state.hasSearched) {
        resetSearchResult();
      }
    };
    parentLogic.state.textEditingController.addListener(_searchTextListener);
    onRankRefresh(0);
    onRankRefresh(1);
    onRankRefresh(2);
  }

  @override
  void onClose() {
    parentLogic.state.textEditingController.removeListener(_searchTextListener);
    for (final PullRefreshController controller
        in state.rankPullRefreshControllers) {
      controller.refreshController.dispose();
      controller.code.dispose();
    }
    super.onClose();
  }

  List<String> hotWords() {
    return parentLogic.state.hotSearchKeywords.take(10).toList();
  }

  void onRankRefresh(int index) {
    _setRankPage(index, 1);
    loadRankList(index);
  }

  void onRankLoad(int index) {
    _setRankPage(index, _rankPage(index) + 1);
    loadRankList(index);
  }

  Future<void> loadRankList(int index) async {
    final page = _rankPage(index);
    final isFirstPage = page == 1;
    final controller = state.rankPullRefreshControllers[index];

    try {
      final rankList = await HomeApis.getRankList(
        rankType: _rankType(index),
        pageNumber: page,
        pageSize: rankPageSize,
      );
      // 排行榜接口返回的就是 [MediaVideoModel]，直接保留：
      // 早期实现绕道 MediaList 做了两次 JSON 互转，会把 vodPic /
      // vodPicInfo 等字段名错配丢掉，导致「本周/本月最热」封面全部消失。
      _setRankList(index, rankList, reset: isFirstPage);
      final hasMore = rankList.length >= rankPageSize;
      final isEmpty = _rankList(index).isEmpty;
      controller.requestSuccess(
        isFirstPageNum: isFirstPage,
        hasMore: hasMore,
        isEmpty: isEmpty,
      );
      update();
    } catch (_) {
      if (!isFirstPage) {
        _setRankPage(index, page > 1 ? page - 1 : 1);
      }
      controller.requestFail(isFirstPageNum: isFirstPage);
      update();
    }
  }

  int _rankType(int index) {
    switch (index) {
      case 1:
        return 5;
      case 2:
        return 6;
      case 0:
      default:
        return 3;
    }
  }

  int _rankPage(int index) {
    switch (index) {
      case 1:
        return state.monthHotPage;
      case 2:
        return state.lastMonthHotPage;
      case 0:
      default:
        return state.weekHotPage;
    }
  }

  void _setRankPage(int index, int page) {
    switch (index) {
      case 1:
        state.monthHotPage = page;
        break;
      case 2:
        state.lastMonthHotPage = page;
        break;
      default:
        state.weekHotPage = page;
    }
  }

  List<MediaVideoModel> _rankList(int index) {
    switch (index) {
      case 1:
        return state.monthHotMediaList;
      case 2:
        return state.lastMonthHotMediaList;
      case 0:
      default:
        return state.weekHotMediaList;
    }
  }

  void _setRankList(
    int index,
    List<MediaVideoModel> list, {
    required bool reset,
  }) {
    switch (index) {
      case 1:
        state.monthHotMediaList =
            reset ? list : [...state.monthHotMediaList, ...list];
        break;
      case 2:
        state.lastMonthHotMediaList =
            reset ? list : [...state.lastMonthHotMediaList, ...list];
        break;
      default:
        state.weekHotMediaList =
            reset ? list : [...state.weekHotMediaList, ...list];
    }
  }

  Future<void> onSearch(String? keyWord) async {
    final text = keyWord?.trim() ?? '';
    if (text.isEmpty) {
      showToast(msg: '请输入要搜索的内容');
      return;
    }

    parentLogic.state.saveKeywords(text);
    if (parentLogic.state.textEditingController.text != text) {
      parentLogic.state.textEditingController.text = text;
    }

    state.searchKeyword = text;
    state.hasSearched = true;
    update();
    parentLogic.refreshSearchRecord();
  }

  void resetSearchResult() {
    state.hasSearched = false;
    state.searchKeyword = '';
    update();
  }
}

import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/utils/tab_controller_dispose.dart';
import 'package:comics_app/pages/common/search_page/search_result/search_result_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'film_search_result_state.dart';

class FilmSearchResultLogic extends GetxController
    with GetTickerProviderStateMixin {
  FilmSearchResultLogic({
    required this.videoType,
    String? initialKeyword,
  }) : state = FilmSearchResultState(videoType: videoType) {
    if (initialKeyword != null && initialKeyword.trim().isNotEmpty) {
      state.keyword = initialKeyword.trim();
    }
  }

  final int videoType;
  final FilmSearchResultState state;

  TabController? sortTabController;
  int _prevSortTabIndex = -1;

  @override
  void onInit() {
    super.onInit();
    _attachSortTabController();
    _syncKeywordFromSearchPage();
    onRefresh();
  }

  void _attachSortTabController() {
    final n = FilmSearchResultState.sortTabs.length;
    sortTabController?.removeListener(_onSortTabChanged);
    sortTabController?.dispose();
    sortTabController = TabController(
      length: n,
      vsync: this,
      initialIndex: state.filterTabIndex.clamp(0, n - 1),
    )..addListener(_onSortTabChanged);
    _prevSortTabIndex = sortTabController!.index;
    state.filterTabIndex = _prevSortTabIndex;
  }

  void _onSortTabChanged() {
    final c = sortTabController;
    if (c == null || c.indexIsChanging) return;
    if (c.index == _prevSortTabIndex) return;
    _prevSortTabIndex = c.index;
    setSortTab(c.index);
  }

  void _syncKeywordFromSearchPage() {
    if (Get.isRegistered<SearchResultLogic>()) {
      final text =
          Get.find<SearchResultLogic>().state.textEditingController.text;
      if (text.trim().isNotEmpty) {
        state.keyword = text.trim();
      }
    }
  }

  void updateKeyword(String? keyword) {
    final text = keyword?.trim() ?? '';
    if (text.isEmpty || text == state.keyword) return;
    state.keyword = text;
    onRefreshAllTabs();
  }

  void setSortTab(int index) {
    if (index < 0 || index >= FilmSearchResultState.sortTabs.length) return;
    if (state.filterTabIndex == index) return;
    state.filterTabIndex = index;
    _prevSortTabIndex = index;
    final c = sortTabController;
    if (c != null && c.length > index && c.index != index) {
      c.animateTo(index);
    }
    onRefresh();
    update();
  }

  void onRefresh({int? tabIndex}) {
    final idx = tabIndex ?? state.filterTabIndex;
    state.tabPageNumbers[idx] = 1;
    getData(tabIndex: idx);
  }

  void onLoad({int? tabIndex}) {
    final idx = tabIndex ?? state.filterTabIndex;
    state.tabPageNumbers[idx]++;
    getData(tabIndex: idx);
  }

  void onRefreshAllTabs() {
    for (var i = 0; i < state.tabPageNumbers.length; i++) {
      state.tabPageNumbers[i] = 1;
      state.tabVideoItems[i] = [];
    }
    getData();
  }

  Future<void> getData({int? tabIndex}) async {
    final idx = tabIndex ?? state.filterTabIndex;
    final keyword = state.keyword?.trim() ?? '';
    final pullRefresh = state.tabPullRefreshControllers[idx];

    if (keyword.isEmpty) {
      pullRefresh.requestFail(isFirstPageNum: true);
      update();
      return;
    }

    try {
      final pageNumber = state.tabPageNumbers[idx];
      final List<MediaVideoModel> list = await HomeApis.getHomeMediaList(
        keyword: keyword,
        videoType: videoType,
        sortType: FilmSearchResultState.sortTypes[idx],
        pageNumber: pageNumber,
        pageSize: state.pageSize,
      );

      if (pageNumber == 1) {
        state.tabVideoItems[idx] = list;
      } else {
        state.tabVideoItems[idx] = <MediaVideoModel>[
          ...state.tabVideoItems[idx],
          ...list,
        ];
      }

      final hasMore = list.length >= state.pageSize;
      final isEmpty = state.tabVideoItems[idx].isEmpty;
      pullRefresh.requestSuccess(
        isFirstPageNum: pageNumber == 1,
        hasMore: hasMore,
        isEmpty: isEmpty,
      );
      update();
    } catch (_) {
      pullRefresh.requestFail(
        isFirstPageNum: state.tabPageNumbers[idx] == 1,
      );
      update();
    }
  }

  @override
  void onClose() {
    final c = sortTabController;
    c?.removeListener(_onSortTabChanged);
    disposeTabControllerAfterRouteExit(c);
    super.onClose();
  }
}

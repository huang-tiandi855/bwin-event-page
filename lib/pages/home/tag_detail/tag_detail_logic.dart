import 'package:comics_app/common/apis/acg_api.dart';
import 'package:comics_app/pages/home/tag_detail/tag_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/entities/MediaListInfo.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';
import '../../common/search_page/search_result/search_result_logic.dart';
import '../../common/search_page/search_result/search_result_state.dart';

class TagDetailLogic extends GetxController with GetTickerProviderStateMixin {
  final state = TagDetailState();
  String? id;
  String? title;
  int? kind;
  int? sortType;
  int currentTab = 0;
  TagDetailLogic({this.title, this.id, this.kind, this.sortType});

  @override
  void onInit() {
    state.tabController =
        TabController(length: state.tabs.length, vsync: this, initialIndex: 0)
          ..addListener(() {
            if (currentTab != state.tabController.index) {
              currentTab = state.tabController.index;
              state.pageNum = 1;
              state.mediaList = [];
              doInit();
            }
          });
    state.title = title ?? Get.arguments["title"] ?? "";
    state.kind = kind ?? Get.arguments["kind"] ?? 0;
    state.id = Get.arguments["tags"];
    super.onInit();
    if (state.id == null) {
      doInit();
    }
    if (state.id == null) {
      SearchResultState? searchResultState =
          Get.find<SearchResultLogic>().state;
      searchResultState.setDoSearch((keyWords) {
        state.title = keyWords;
        state.pageNum = 1;
        state.mediaList = [];
        state.tagMediaList = [];
        doInit();
      });
    }
  }

  void doInit() async {
    try {
      if (state.id == null) {
        state.pullRefreshController.code =
            ValueNotifier(PULL_REQUEST_CODE.REQUESTING);
        final resp = await ACGApi.searchNewKeyWord({
          "kind": state.kind,
          "keyword": state.title,
          "page": state.pageNum,
          "pageSize": 12,
          "sortType": state.tabController.index
        });

        if (state.pageNum == 1) {
          state.isLoading = true;
          state.mediaList = [];
          update(['mediaList']);
        }

        if (resp != null) {
          final model = MediaListInfo.fromJson(resp);
          if (state.pageNum == 1) {
            state.tagMediaList = model.data?.tagList ?? [];
            state.tagsId = model.data?.tagID.isNotEmpty == true
                ? model.data?.tagID
                : null;
            state.mediaList = model.data?.mediaList ?? [];
            state.pullRefreshController.refreshController
                .refreshCompleted(resetFooterState: true);
          } else {
            state.mediaList = state.mediaList
              ..addAll(model.data?.mediaList ?? []);
          }
          state.pullRefreshController.requestSuccess(
            isFirstPageNum: state.pageNum == 1 ? true : false,
            hasMore: model.data?.hasNext ?? false,
            isEmpty: state.mediaList.isEmpty && state.tagMediaList.isEmpty,
          );
        } else {
          state.pullRefreshController
              .requestFail(isFirstPageNum: state.pageNum == 1);
        }
      }
    } catch (e) {
      state.pullRefreshController
          .requestFail(isFirstPageNum: state.pageNum == 1);
    }

    if (state.isLoading) {
      state.isLoading = false;
    }

    update();
  }
}

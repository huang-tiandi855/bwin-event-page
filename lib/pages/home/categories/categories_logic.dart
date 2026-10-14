import 'dart:math';

import 'package:comics_app/common/apis/acg_api.dart';
import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/entities/MediaListInfo.dart';
import 'package:comics_app/common/entities/categories_entity.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'categories_state.dart';

class CategoriesLogic extends GetxController {
  final CategoriesState state = CategoriesState();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    state.categoriesAds = getAdsByType(AdsType.banner);

    state.categoriesAdsHorizonal = getAdsByType(AdsType.banner);

    state.scrollController.addListener(() {
      if (state.scrollController.offset > 248) {
        List<String> tagNames = [];
        for (int i = 0; i < state.selectedTags.length; i++) {
          if (state.selectedTags[i] != -1) {
            final tagIndex = state.selectedTags[i];
            final tag =
                state.categoriesEntity?.data?.list?[i].tags?[tagIndex].name;
            if (tag?.isNotEmpty ?? false) {
              tagNames.add(tag!);
            }
          }
        }
        state.selectedTagsName = tagNames.join('·');
        if (!state.isShowHeader) {
          showHeader(true);
        }
      } else {
        showHeader(false);
      }
    });

    state.selectTypes[-1] = state.tabs[0];

    doInit(0);
  }

  //热门搜索（已禁用）
  Future guessLike() async {
    return;
  }

  void updateListView(bool horizontal) {
    state.isHorizontal = horizontal;
    update();
  }

  //初始化数据
  void doInit(int? kind) async {
    Map<String, dynamic> data = {
      'kind': kind,
    };

    Map<String, dynamic> entity = await UserApi.getClassifyTag(data);

    state.categoriesEntity = CategoriesEntity.fromJson(entity);

    state.selectedTags = List.generate(
        state.categoriesEntity?.data?.list?.length ?? 0, (index) => -1);

    state.isFirstEnter = true;
    update(['page']);
    await searchVideo();

    await guessLike();
  }

  Future searchVideo({bool isLoadByScroll = false}) async {
    List<String> tags = [];
    for (int i = 0; i < state.selectedTags.length; i++) {
      if (state.selectedTags[i] != -1) {
        final tagIndex = state.selectedTags[i];
        final tag = state.categoriesEntity?.data!.list?[i].tags?[tagIndex].id;
        if (tag?.isNotEmpty ?? false) {
          tags.add(tag!);
        }
      }
    }

    Map<String, dynamic> data = {
      "kind": state.selectedKind,
      "page": state.pageNum,
      "pageSize": 20,
      "tags": tags,
    };

    var entity = await ACGApi.getHotCategory(data);

    MediaListInfo mediaListInfo = MediaListInfo.fromJson(entity);

    if (state.pageNum > 1) {
      state.mediaListInfo?.data?.mediaList
          ?.addAll(mediaListInfo.data!.mediaList!);

      if (mediaListInfo.data!.hasNext!) {
        state.pullRefreshController.refreshController.loadComplete();
      } else {
        state.pullRefreshController.refreshController.loadNoData();
      }
    } else {
      state.mediaListInfo = mediaListInfo;
      state.pullRefreshController.refreshController.refreshCompleted();
    }

    // state.isLoading = false;

    //state.pullRefreshController.requestSuccess(isFirstPageNum: true, hasMore: mediaListInfo.data!.hasNext ?? false);

    //state.pullRefreshController.requestSuccess(isFirstPageNum: true, hasMore: true);

    if (mediaListInfo.data!.hasNext!) {
      state.pullRefreshController.requestSuccess(
          isFirstPageNum: true, hasMore: mediaListInfo.data!.hasNext ?? false);

      if (!isLoadByScroll) {
        state.guessLikeMediaListInfo = null;
        state.guessLikePageNum = 1;
        state.guessLikeMediaList.clear();
      }

      state.isLoadingEmpty = false;

      update(["list"]);
    } else {
      state.isLoadingEmpty = true;
      state.guessLikePageNum = state.guessLikePageNum + 1;
      guessLike();
      update(["list"]);
      state.pullRefreshController.refreshController.loadNoData();
    }
  }

  Future setSelected(int columnIndex, int rowIndex) async {
    state.isFirstEnter = false;
    state.pageNum = 1;

    if (state.selectedTags[columnIndex] != rowIndex) {
      state.selectedTags[columnIndex] = rowIndex;
    } else {
      state.selectedTags[columnIndex] = -1;
    }

    update(['category']);
    await searchVideo();
  }

  void clickKind(String e) {
    if (e == "COS" || e == "真人") {
      updateListView(true);
    } else {
      updateListView(false);
    }
    state.selectedTags = List.generate(
        state.categoriesEntity?.data?.list?.length ?? 0, (index) => -1);
    state.mediaListInfo?.data?.mediaList!.clear();
    state.selectedKind = state.tabs.indexOf(e);
    doInit(state.tabs.indexOf(e));
    update(['category']);
  }

  void showHeader(bool show) {
    if (show != state.isShowHeader) {
      state.isShowHeader = show;

      update(['category_overlazy']);
    }
  }

  void toggleOverlazyExpand() {
    state.overlazyExpand = !state.overlazyExpand;
    update(['category_overlazy']);
  }

  void toggleHeaderExpand() {
    state.headerExpand = !state.headerExpand;
    update(['category']);
  }

  void innerScrollListener() {
    if (state.isShowHeader && state.overlazyExpand) {
      toggleOverlazyExpand();
    }
  }

  void outerScrollListener() {
    innerScrollListener();
    final maxScrollExtent =
        (state.key.currentState?.outerController.position.maxScrollExtent ?? 0);
    double targetOffset =
        state.headerExpand ? max((maxScrollExtent - 18.w), 0.0) : 0;
    if ((state.key.currentState?.outerController.offset ?? 0) > targetOffset) {
      if (!state.isShowHeader) {
        showHeader(true);
      }
    } else {
      showHeader(false);
    }
  }

  void reset() {
    state.overlazyExpand = false;
    state.headerExpand = true;
    update(['category', 'category_overlazy']);
    showHeader(false);
    try {
      state.key.currentState?.outerController.jumpTo(0);
    } catch (_) {
      // 列表未挂载时忽略
    }
  }
}

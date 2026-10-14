import 'package:comics_app/common/apis/section_api.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/apis/module_api.dart';
import '../../../common/entities/acg_section/section_model.dart';
import '../../../common/entities/module_detail_model/module_detail_model.dart';
import '../../../common/utils/ads_manage/ads_insert_utils.dart';
import 'comic_state.dart';

class ComicLogic extends GetxController with GetSingleTickerProviderStateMixin {
  String? moduleId;

  ComicLogic(this.moduleId);

  final ComicState state = ComicState();
  final ValueNotifier<int> selectIndex = ValueNotifier<int>(0);
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    state.banner = getAdsByType(AdsType.banner);
    getData();

    Map map = {};

    map["链路"] = "首页-漫画";

    ConfigStore.to.trackData('首页浏览', map);
  }

  getSee() async {
    var info = state.featureEntity?.allSection.last;
    final resp = await SectionApi.getMedialTopicDetailList(
      sectionId: info?.sectionId ?? "",
      sortType: 1,
      pageNumber: state.seePageNum,
      pageSize: 12,
    );
    if (resp.isSuccess) {
      final model = SectionModel.fromJson(resp.data);
      bool hasMore = model.hasNext ?? false;
      if (state.topicSectionModel == null || state.seePageNum == 1) {
        state.topicSectionModel = model;
      } else if (model.mediaList?.isNotEmpty == true) {
        state.topicSectionModel?.mediaList?.addAll(model.mediaList!);
        state.pullRefreshControllerComic.refreshController.refreshCompleted(resetFooterState: true);
      }
      state.pullRefreshControllerComic.requestSuccess(
        isFirstPageNum: false,
        hasMore: hasMore,
        isEmpty: false,
      );
      update();
    } else {
      state.pullRefreshControllerComic.requestFail(isFirstPageNum: state.pageNum == 1);
    }
  }

  bool isSeeType() {
    bool isSeeType = state.pageNum > 1 && state.featureEntity?.allSection.isNotEmpty == true;
    var info = state.featureEntity?.allSection.last;
    isSeeType = info?.showType == 28;
    return isSeeType;
  }

  bool isHideMore(var item) {
    bool isSeeType = state.pageNum > 1 && state.featureEntity?.allSection.isNotEmpty == true;
    var info = state.featureEntity?.allSection.last;
    isSeeType = info?.showType == 28;
    return isSeeType && item.sectionId != null && item.sectionId == info?.sectionId;
  }

  getData() async {
    try {
      final resp = await ModuleApi.getVidModuleDetail(moduleId ?? "", pageNumber: state.pageNum, subModuleId: moduleId);
      if (resp.isSuccess) {
        try {
          final model = ModuleDetailModel.fromJson(resp.data);
          bool hasMore = model.hasNext ?? false;

          bool isEmpty = false;
          if (state.pageNum == 1) {
            state.featureEntity = model;
          } else {
            state.featureEntity = state.featureEntity?.applyWith(model);
          }
          if (!hasMore) {
            hasMore = isSeeType();
          }
          AdsInsertUtils.handelAdsSource(state.featureEntity?.allSection??[], adPos: AdsType.banner, adGap: 2);
          state.pullRefreshControllerComic.requestSuccess(
            isFirstPageNum: state.pageNum == 1,
            hasMore: hasMore,
            isEmpty: isEmpty,
          );

          update();
          return;
        } catch (e) {
          e.printError();
          state.pullRefreshControllerComic.requestFail(isFirstPageNum: state.pageNum == 1);
        }
      }
      state.pullRefreshControllerComic.requestFail(isFirstPageNum: state.pageNum == 1);
    } catch (e) {
      state.pullRefreshControllerComic.requestFail(isFirstPageNum: state.pageNum == 1);
    }
  }

  void initController(int length) {
    state.rankTabController ??= TabController(length: length, vsync: this);
  }
}

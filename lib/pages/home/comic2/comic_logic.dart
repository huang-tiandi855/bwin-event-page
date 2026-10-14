import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/apis/module_api.dart';
import '../../../common/entities/module_detail_model/module_detail_model.dart';
import 'comic_state.dart';

class ComicLogic2 extends GetxController with GetSingleTickerProviderStateMixin {
  String? moduleId;
  int? showTabNum;

  ComicLogic2(this.moduleId, {this.showTabNum});

  final ComicState2 state = ComicState2();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    if (showTabNum != null) {
      state.moduleSort = 1;
      state.tabController = TabController(vsync: this, length: showTabNum!)
        ..addListener(() async {
          state.moduleSort = showTabNum == 2
              ? state.tabValues[state.tabController.index].value
              : state.tabVal[state.tabController.index].value;
          state.pageNum = 1;
          await getData();
        });
      state.currentTabs =
          showTabNum == 2 ? state.tabValues.map((e) => e.name).toList() : state.tabVal.map((e) => e.name).toList();
    }
    state.banner = getAdsByType(AdsType.banner);
    getData();

    Map map = {};

    map["链路"] = "首页-漫画";

    ConfigStore.to.trackData('首页浏览', map);
  }

  getData() async {
    try {
      final resp = await ModuleApi.getVidModuleDetail(moduleId ?? "",
          pageNumber: state.pageNum, pageSize: 12, moduleSort: state.moduleSort);
      if (resp.isSuccess) {
        try {
          final model = ModuleDetailModel.fromJson(resp.data);
          bool hasMore = model.hasNext ?? false;
          bool isEmpty = false;
          if (state.pageNum == 1) {
            state.moduleDetailModel = model;
          } else {
            state.moduleDetailModel = state.moduleDetailModel?.applyWith(model);
          }
          state.itemCount = state.moduleDetailModel?.allMediaInfo.length??0;

          state.pullRefreshControllerComic.requestSuccess(
            isFirstPageNum: state.pageNum == 1,
            hasMore: hasMore,
            isEmpty: isEmpty,
          );
          update();
        } catch (e) {
          state.pullRefreshControllerComic.requestFail(isFirstPageNum: state.pageNum == 1);
        }
      }
      // state.pullRefreshControllerComic.requestFail(isFirstPageNum: state.pageNum == 1);
    } catch (e) {
      state.pullRefreshControllerComic.requestFail(isFirstPageNum: state.pageNum == 1);
    }
  }
}

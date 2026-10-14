import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../common/apis/module_api.dart';
import '../../../common/entities/module_detail_model/module_detail_model.dart';
import 'novel_state.dart';

class NovelLogic2 extends GetxController {
  final NovelState2 state = NovelState2();
  final String? moduleId;
  NovelLogic2(this.moduleId);
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    state.banner = getAdsByType(AdsType.banner);
    doInit();

    Map map = {};

    map["链路"] = "首页-小说";

    ConfigStore.to.trackData('首页浏览',map);
  }

  //初始化数据
  void doInit() async {
    state.pullRefreshNovelController.code =
        ValueNotifier(PULL_REQUEST_CODE.REQUESTING);
    getData();
  }

  getData() async {
    try {
      final resp = await ModuleApi.getVidModuleDetail(
          moduleId??"",
          pageNumber: state.pageNum,
          pageSize: 12
      );
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
          state.pullRefreshNovelController.requestSuccess(
            isFirstPageNum: state.pageNum == 1,
            hasMore: hasMore,
            isEmpty: isEmpty,
          );
          update();
          return;
        } catch (e) {
          state.pullRefreshNovelController.requestFail(isFirstPageNum: state.pageNum == 1);
        }
      }
      state.pullRefreshNovelController.requestFail(isFirstPageNum: state.pageNum == 1);
    } catch (e) {
      state.pullRefreshNovelController.requestFail(isFirstPageNum: state.pageNum == 1);
    }
  }
}

import 'package:comics_app/common/apis/acg_api.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/pages/home/tag_detail/tag_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/entities/acg_section/rank_model.dart';
import '../../../../common/entities/acg_section/section_model.dart';
import '../../../../common/entities/config.dart';
import '../../../../common/utils/ads_manage/getAdv.dart';
import '../../../../common/widgets/pullRefreshView/pull_refresh_view.dart';

class TagSubDetailLogic extends GetxController with GetTickerProviderStateMixin {
  final state = TagDetailState();

  String? id;
  String? title;
  int? kind;
  int? sortType;

  List<AdsInfoList> categoriesAds = getAdsByType(AdsType.banner);
  int currentTab = 0;
  bool isSubTabView;
  TagSubDetailLogic({this.title, this.id, this.kind, this.sortType, this.isSubTabView = false});

  @override
  void onInit() {
    super.onInit();
    if (kind != null) {
      state.kind = kind!;
    }
    if (id != null) state.id = id;
    isSubTabView = Get.arguments["isSub"] ?? false;
    doInit();
  }

  void doInit() async {
    state.pullRefreshController.code = ValueNotifier(PULL_REQUEST_CODE.REQUESTING);
    try {
      if (state.id != null) {
        if (isSubTabView) {
          BaseRespBean resp = await ACGApi.searchNewTags({
            "tagIDs": id,
            "page": state.pageNum,
            "pageSize": 12,
            "sortType": sortType ?? 0,
            "kind": state.kind
          });

          if (resp.isSuccess) {
            final model = RankModel.fromJson(resp.data);
            var list = model.mediaList ?? [];
            if (state.pageNum == 1) {
              state.tagSubMediaList = list;
              state.pullRefreshController.refreshController.refreshCompleted(resetFooterState: true);
            } else {
              state.tagSubMediaList = state.tagSubMediaList..addAll(list);
            }
            state.realTagSubMediaList = state.tagSubMediaList;
            printInfo(info: "${state.mediaList.length}");
            state.pullRefreshController.requestSuccess(
              isFirstPageNum: state.pageNum == 1 ? true : false,
              hasMore: model.hasNext ?? false,
              isEmpty: state.tagSubMediaList.isEmpty,
            );
          } else {
            state.pullRefreshController.requestFail(isFirstPageNum: state.pageNum == 1);
          }
        } else {
          BaseRespBean resp = await ACGApi.getTagsList(
              sortType: sortType ?? 0, tid: id!, kind: kind, pageSize: state.pageSize, pageNumber: state.pageNum);
          if (resp.isSuccess) {
            final model = SectionModel.fromJson(resp.data);
            var list = model.mediaList ?? [];
            if (state.pageNum == 1) {
              state.tagSubMediaList = list;
              state.pullRefreshController.refreshController.refreshCompleted(resetFooterState: true);
            } else {
              state.tagSubMediaList = state.tagSubMediaList..addAll(list);
            }
            state.pullRefreshController.requestSuccess(
              isFirstPageNum: state.pageNum == 1 ? true : false,
              hasMore: model.hasNext ?? false,
              isEmpty: state.tagSubMediaList.isEmpty,
            );
            state.realTagSubMediaList = getRealList();
          } else {
            state.pullRefreshController.requestFail(isFirstPageNum: state.pageNum == 1);
          }
        }
      }
    } catch (e) {
      state.pullRefreshController.requestFail(isFirstPageNum: state.pageNum == 1);
    }

    update();
  }

  void getTagList() async {}

  List<AllMediaInfoModel> getRealList() {
    var lists = state.tagSubMediaList;
    if (categoriesAds.isNotEmpty == true) {
      for (int i = 0; i < lists.length; i++) {
        if ((i + 1) % 5 == 0) {
          int j = ((i) / 4).round();
          int index;
          if (j % categoriesAds.length == 0) {
            index = categoriesAds.length - 1;
          } else {
            index = (j % categoriesAds.length - 1);
          }
          var ad = categoriesAds[index];
          lists.insert(
              i,
              AllMediaInfoModel.ad(
                  id: ad.id, cover: ad.resourceUrl, verticalCover: ad.resourceUrl, title: ad.title, adUrl: ad.externalLink));
        }
      }
    }
    return lists;
  }
}

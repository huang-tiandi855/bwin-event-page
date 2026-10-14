import 'package:comics_app/common/apis/section_api.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:get/get.dart';

import '../../../../../common/utils/ads_manage/getAdv.dart';
import '../../../common/entities/acg_section/section_model.dart';
import '../topic/topic_logic.dart';
import 'topic_detail_state.dart';

class TopicDetailLogic extends GetxController {
  final int simpleSort;
  bool? isJinGangZone;
  TopicDetailLogic(this.simpleSort, this.isJinGangZone);
  final TopicDetailState state = TopicDetailState();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    final topicLogicState = Get.find<TopicLogic>().state;
    state.id = topicLogicState.id;
    state.title = topicLogicState.title;

    doInit();

    Map map = {};

    map["state.title"] =
        topicLogicState.tabs.elementAt(topicLogicState.tabController.index);
    map["链路"] =
        "首页-${topicLogicState.tabs.elementAt(topicLogicState.tabController.index)}-更多";

    ConfigStore.to.trackData('首页浏览', map);
  }

  //初始化数据
  void doInit() async {
    getData();
  }

  getData() async {
    try {
      final resp = await SectionApi.getMedialTopicDetailList(
          sectionId: state.id ?? "",
          pageNumber: state.pageNum,
          pageSize: state.pageSize,
          sortType: simpleSort);
      if (resp.isSuccess) {
        final model = SectionModel.fromJson(resp.data);
        if (state.pageNum == 1) {
          state.topicDetail = model;
          state.pullRefreshController.refreshController
              .refreshCompleted(resetFooterState: true);
        } else {
          state.topicDetail?.mediaList?.addAll(model.mediaList!);
        }
        state.topicDetail?.mediaList =
            _buildListWithAds(state.topicDetail?.mediaList ?? []);
        state.pullRefreshController.requestSuccess(
          isFirstPageNum: state.pageNum == 1 ? true : false,
          hasMore: model.hasNext ?? false,
          isEmpty: state.topicDetail?.mediaList?.isEmpty ?? true,
        );
      } else {
        state.pullRefreshController
            .requestFail(isFirstPageNum: state.pageNum == 1);
      }
    } catch (e) {
      e.printInfo();
      state.pullRefreshController
          .requestFail(isFirstPageNum: state.pageNum == 1);
    }
    update();
  }

  List<AllMediaInfoModel> _buildListWithAds(List<AllMediaInfoModel> list) {
    final originalList = List<AllMediaInfoModel>.from(list)
      ..removeWhere((element) => element.isAd);
    state.ads ??= getAdsByType(
      state.isVerticalCover
          ? AdsType.banner
          : AdsType.banner,
    );
    if (state.ads?.isNotEmpty ?? false) {
      int adIndex = 0;
      for (int i = 0; i < originalList.length; i++) {
        // 当不足时重头开始取
        if (adIndex >= state.ads!.length) {
          adIndex = 0;
        }
        if ((i + 1) % 5 == 0) {
          final e = state.ads![adIndex];
          originalList.insert(
            i,
            AllMediaInfoModel.ad(
              id: e.id,
              title: e.title,
              cover: state.isVerticalCover ? null : e.resourceUrl,
              verticalCover: state.isVerticalCover ? e.resourceUrl : null,
              adUrl: e.externalLink,
            ),
          );
          adIndex++;
        }
      }
    }
    return originalList;
  }
}

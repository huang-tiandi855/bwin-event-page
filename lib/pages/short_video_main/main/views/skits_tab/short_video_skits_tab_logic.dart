import 'package:comics_app/common/apis/module_api.dart';
import 'package:comics_app/common/entities/module_detail_model/all_section_model.dart';
import 'package:comics_app/common/entities/module_detail_model/module_detail_model.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:get/get.dart';

import 'short_video_skits_tab_state.dart';

class ShortVideoSkitsTabLogic extends GetxController {
  final int? moduleSort;

  final ModuleModel module;

  String get id => module.id!.toString();

  String get tag => '${id}_$moduleSort';

  ShortVideoSkitsTabLogic({required this.module, this.moduleSort});

  final state = ShortVideoSkitsTabState();

  @override
  void onInit() {
    super.onInit();
    onRefresh();
  }

  void onRefresh() async {
    state.pageNumber = 1;
    getData();
  }

  onLoad() async {
    state.pageNumber++;
    getData();
  }

  getData() async {
    try {
      final resp = await ModuleApi.getVidModuleDetail(
        id,
        moduleSort: moduleSort,
        pageNumber: state.pageNumber,
      );
      if (resp.isSuccess) {
        try {
          ModuleDetailModel model = ModuleDetailModel.fromJson(resp.data);
          final banner = model.allSection
              .where((element) => element.showType == 15)
              .toList();

          // 从model中移除banner
          model.allSection.removeWhere((element) => element.showType == 15);

          if (state.pageNumber == 1) {
            state.moduleDetailModel = model;
            state.banner = banner;
            update(['banner']);
          } else {
            // 组合样式存在某些section无限加载需要合并数据
            final sectionList = (state.moduleDetailModel?.allSection ?? []);
            // 获取到的数据合并到原来的allSection中
            for (var e in model.allSection) {
              final index = sectionList
                  .indexWhere((element) => element.sectionId == e.sectionId);

              if (index == -1) {
                // 新的section
                sectionList.add(e);
              } else {
                // 旧的section
                sectionList[index].allMediaInfo =
                    sectionList[index].allMediaInfo..addAll(e.allMediaInfo);
              }
            }
            state.moduleDetailModel = state.moduleDetailModel?.copyWith(
              allSection: sectionList,
              hasNext: model.hasNext,
            );
          }
          bool hasMore = model.hasNext ?? false;
          bool isEmpty = state.moduleDetailModel?.allSection.isEmpty ?? true;

          state.pullRefreshController.requestSuccess(
            isFirstPageNum: state.pageNumber == 1,
            hasMore: hasMore,
            isEmpty: isEmpty,
          );
          update(['list']);
          return;
        } catch (e) {
          state.pullRefreshController
              .requestFail(isFirstPageNum: state.pageNumber == 1);
        }
      }
      state.pullRefreshController
          .requestFail(isFirstPageNum: state.pageNumber == 1);
    } catch (e) {
      state.pullRefreshController
          .requestFail(isFirstPageNum: state.pageNumber == 1);
    }
  }

  void onMoreTap(
    AllSectionModel section,
  ) async {
    if (section.linkUrl?.isNotEmpty == true) {
      AppNavigator.to.jumpUrl(
        url: section.linkUrl!,
        moduleType: 1,
        linkType: section.linkType ?? 1,
        id: section.sectionId,
        title: section.sectionName,
      );
    } else {
      Get.toNamed(AppRoutes.TOPIC_PAGE, arguments: {
        'title': section.sectionName,
        'id': section.sectionId,
        'isSkits': true,
      });
    }
  }
}

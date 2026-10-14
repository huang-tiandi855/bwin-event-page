import 'dart:async';

import 'package:comics_app/common/apis/apis.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/event_bus/event_bus_util.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:comics_app/pages/home/tag_detail/tag_detail_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/entities/MediaListInfo.dart';
import '../../common/services/module_config_service.dart';
import '../../generated/assets.dart';
import '../circle/circle_state.dart';
import 'original_area_section.dart';
import 'original_banner_video.dart';

class OriginalLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  OriginalAreaSectionData? originalDataModel;

  List<OriginalBannerVideoList> bannerList = [];

  final DarkJumpModuleEvent? initialJumpEevent;

  bool isLoading = false;

  late List<TabItem> tabs = [];

  late TabController tabController;

  var tabSelectIndex = 0.obs;

  late StreamSubscription subscription;

  OriginalLogic({
    required this.initialJumpEevent,
  });

  @override
  void onInit() {
    loadTabData();
    eventBusCallback(initialJumpEevent);

    tabController = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: tabSelectIndex.value,
    );
    update();
    tabController.addListener(() {
      tabSelectIndex.value = tabController.index;
    });
    subscription = eventBus.on<DarkJumpModuleEvent>(eventBusCallback);
    super.onInit();
  }

  @override
  void onClose() {
    eventBus.off(subscription);
    super.onClose();
  }

  void eventBusCallback(DarkJumpModuleEvent? event) {
    if (event == null) {
      return;
    }
    int index = tabs.indexWhere((element) => element.bizId == event.id);
    if (index != -1) {
      if (!initialized) {
        tabSelectIndex.value = index;
      } else {
        tabController.animateTo(index);
      }
      return;
    }
  }

  void loadTabData() {
    for (var element in ModuleConfigService().homeModules.homeModules) {
      if (element.moduleName == '有声漫') {
        tabs.add(TabItem(
            selectImage: Assets.imagesOriginComics,
            normalImage: Assets.imagesOriginComicsNormal,
            bizId: element.id.toString()));
      } else if (element.moduleName == '小师妹') {
        tabs.add(TabItem(
            selectImage: Assets.imagesOriginSister,
            normalImage: Assets.imagesOriginSisterNormal,
            bizId: element.id.toString()));
      } else if (element.moduleName == '会员专题') {
        tabs.add(TabItem(
            selectImage: Assets.imagesOriginVip,
            normalImage: Assets.imagesOriginVipNormal,
            bizId: element.id.toString()));
      }
    }
  }

  void initData() {
    isLoading = true;
    update();
    Future.wait([getBannerData(), getListData()]).whenComplete(() {
      isLoading = false;
      update();
    });
  }

  Future<void> getBannerData() async {
    try {
      final baseRes = await UserApi.getOriginalBannerVideo();
      final originalDataModel = OriginalBannerVideoData.fromJson(baseRes);
      bannerList = originalDataModel.list ?? [];
    } catch (_) {
      // 网络/解析失败时保持原有 banner 列表
    }
  }

  Future<void> getListData() async {
    try {
      final baseRes = await UserApi.getOriginalArea();
      originalDataModel = OriginalAreaSectionData.fromJson(baseRes);
    } catch (_) {
      // 网络/解析失败时保持原有列表
    }
  }

  void onIndexChanged(int value) {
    // selectIndex = value;
    // update();
  }

  void onMediaTap(
    int sectionIndex,
    NormalSection normalSection,
    int mediaIndex,
  ) {
    final mediaItem = normalSection.media![mediaIndex];
    ConfigStore.to.trackData(
        '作品点击',
        ConfigStore.to.getClickProductInfoMap(
            MediaList.fromJson(mediaItem.toJson()), "原创-推荐"));

    if (isVideo(mediaItem.kind)) {
      Get.toNamed(AppRoutes.VIDEO_PAGE, arguments: {"id": mediaItem.id});
    } else {
      if (mediaItem.kind == 5) {
        Get.toNamed(AppRoutes.PORTRAY, arguments: {
          "id": mediaItem.id,
          "imageList": normalSection.media,
          "index": sectionIndex,
        });
      }

      if (mediaItem.kind == 4) {
        Get.toNamed(AppRoutes.NOVEL_DETAILS_PAGE, arguments: {
          "id": mediaItem.id,
          "type": MediaKind.mediaKindRealFiction,
        });
      }
      if (mediaItem.kind == 1) {
        Get.toNamed(AppRoutes.NOVEL_DETAILS_PAGE,
            arguments: {"id": mediaItem.id, "type": MediaKind.mediaKindComics});
      }
    }
  }

  void onTagTap(Media item, int index) {
    Get.delete<TagDetailLogic>();
    Get.toNamed(AppRoutes.TAGS_DETAIL, arguments: {
      "title": item.tagNames?[index],
      "kind": item.kind,
      "tags": item.tags?[index],
    });
  }

  void onTapSection(Section section) {
    Get.toNamed(AppRoutes.ORIGINAL_TOPIC_PAGE, arguments: {
      "title": section.name,
      "id": section.id,
      "zone": section.zone,
    });
  }
}

import 'package:comics_app/common/utils/event_bus/event_bus_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/entities/modules_config/module_model.dart';

/// 圈子 · 帖子分类加载状态。
enum CircleCategoryLoadStatus {
  /// 接口请求中（含首次加载和重试）
  loading,

  /// 请求成功（`postingCategory` 可能为空）
  success,

  /// 请求失败，需要重试
  failed,
}

class CircleState {
  late TabController tabController;

  /// 默认「社区」首页
  var tabSelectIndex = 0.obs;
  var tabPostingIndex = 0.obs;
  int? jumpPostingModuleId;
  // var isFabVisible = true.obs;

  CirclePhotoJumpModuleEvent? circlePhotoJumpModuleEvent;

  ///帖子分类
  List<ModuleModel> postingCategory = [];

  /// 帖子分类加载状态，初始为 [CircleCategoryLoadStatus.loading]。
  CircleCategoryLoadStatus postingCategoryStatus =
      CircleCategoryLoadStatus.loading;

  CircleState() {
    ///Initialize variables
  }
}

class TabItem {
  String? selectImage;
  String? normalImage;
  String? bizId;

  TabItem({this.selectImage, this.normalImage, this.bizId});

  @override
  String toString() {
    return 'TabItem{selectImage: $selectImage, normalImage: $normalImage, bizId: $bizId}';
  }
}

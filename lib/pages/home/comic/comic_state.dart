import 'package:card_swiper/card_swiper.dart';
import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';

import '../../../common/entities/acg_section/section_model.dart';
import '../../../common/entities/module_detail_model/module_detail_model.dart';

class ComicState {
  ModuleDetailModel?  featureEntity;

  late PullRefreshController pullRefreshControllerComic =
      PullRefreshController();

  late List<AdsInfoList> banner = [];

  int pageNum = 1;

  int selectIndex = 0;

  bool isLoading = false;

  int seePageNum = 1;
  SectionModel? topicSectionModel;

  SwiperController? swiperController = SwiperController();
  TabController? rankTabController;

  ComicState() {
    ///Initialize variables
  }
}

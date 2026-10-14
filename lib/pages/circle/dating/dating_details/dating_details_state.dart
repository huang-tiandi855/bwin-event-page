import 'package:comics_app/common/entities/circle/dating_models.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/card_swiper/src/swiper_controller.dart';

class DatingDetailsState {
  int datingId = 0;
  DatingCardModel? card;
  bool loading = true;
  bool loadFailed = false;

  final ScrollController scrollController = ScrollController();
  final PullRefreshController relatedPullController = PullRefreshController();

  List<DatingCardModel> relatedCards = const <DatingCardModel>[];
  int relatedPage = 1;
  bool relatedHasMore = true;
  static const int relatedPageSize = 10;

  List<DatingDictItem> reportTypes = const <DatingDictItem>[];

  final SwiperController swiperController = SwiperController();
  int selectedImageIndex = 0;
}

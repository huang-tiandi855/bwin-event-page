import 'package:get/get.dart';

import '../../../../../common/entities/config.dart';
import '../../../../../common/widgets/pullRefreshView/pull_refresh_view.dart';
import '../../../common/entities/acg_section/section_model.dart';

class TopicDetailState {
  String? id;

  late PullRefreshController pullRefreshController = PullRefreshController();

  SectionModel? topicDetail;

  int pageNum = 1;
  int pageSize = 12;
  String title = '';
  int topicId = 0;

  String? zone;

  bool? isJinGangZone;

  TopicDetailState() {
    ///Initialize variables
    ///
    ///
    zone = Get.arguments["zone"];
    isVerticalCover = Get.arguments['isVerticalCover'] ?? true;
  }

  List<AdsInfoList>? ads;

  bool isVerticalCover = true;
}

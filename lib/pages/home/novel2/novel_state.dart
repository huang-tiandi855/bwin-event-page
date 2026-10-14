import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

import '../../../common/entities/module_detail_model/module_detail_model.dart';

class NovelState2 {
  ModuleDetailModel? moduleDetailModel;

  late PullRefreshController pullRefreshNovelController =
      PullRefreshController();

  late List<AdsInfoList> banner = [];

  int pageNum = 1;

  int selectIndex = 0;

  NovelState2() {
    ///Initialize variables
  }
}

import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

import '../../../common/entities/module_detail_model/module_detail_model.dart';

class CartoonState10 {
  ModuleDetailModel? moduleDetailModel;

  late List<AdsInfoList> banner = [];

  late PullRefreshController pullRefreshCartoonController =
      PullRefreshController();

  int pageNum = 1;

  int selectIndex = 0;

  CartoonState10() {
    ///Initialize variables
  }
}
